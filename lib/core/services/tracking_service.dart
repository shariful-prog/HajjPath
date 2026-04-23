import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'location_service.dart';

import '../config/app_config.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final LocationService _locationService = LocationService();
  final DatabaseService _dbService = DatabaseService();
  final Battery _battery = Battery();
  
  final FirebaseDatabase _firebaseDb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConfig.firebaseDatabaseUrl,
  );

  Position? _lastPosition;
  DateTime? _lastLiveUpdateTime;
  DateTime? _lastBatchUploadTime;
  DateTime? _lastHistorySaveTime;

  Future<void> processTrackingTick(String username, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Check if tracking is enabled
    final bool trackingEnabled = prefs.getBool('tracking_enabled') ?? true;
    if (!trackingEnabled) {
      debugPrint('Tracking disabled in settings.');
      return;
    }

    // 2. Check Sleep Mode
    if (await _isSleepModeActive(prefs)) {
      debugPrint('Sleep Mode is active. Skipping tracking.');
      return;
    }

    // 3. (Removed explicit skipping here, handled by adaptive logic below)

    // 4. Get Current Position
    Position position;
    try {
      position = await _locationService.getCurrentPosition();
    } catch (e) {
      debugPrint('GPS Error: $e');
      return;
    }

    // 5. Adaptive SQLite Storage Logic
    final batteryLevel = await _battery.batteryLevel;
    final batteryState = await _battery.batteryState;
    final bool isCharging = batteryState == BatteryState.charging;
    
    double distance = 0;
    bool shouldSaveHistory = false;
    final now = DateTime.now();

    if (_lastPosition != null) {
      distance = _locationService.calculateDistance(
        _lastPosition!.latitude, _lastPosition!.longitude,
        position.latitude, position.longitude
      );
      
      double speedKmh = position.speed * 3.6;

      if (distance < 20 && speedKmh < 2) {
        // Stationary or very slow: Heartbeat mode (30 minutes)
        if (_lastHistorySaveTime == null || now.difference(_lastHistorySaveTime!).inMinutes >= 30) {
          shouldSaveHistory = true;
          debugPrint('Heartbeat point captured.');
        } else {
          debugPrint('Stationary (moved ${distance.toStringAsFixed(1)}m). Skipping capture.');
        }
      } else if (speedKmh > 15) {
        // Fast Movement: Capture every 1 minute
        if (_lastHistorySaveTime == null || now.difference(_lastHistorySaveTime!).inMinutes >= 1) {
          shouldSaveHistory = true;
        }
      } else {
        // Walking/Normal Movement: Capture every 2 minutes
        if (_lastHistorySaveTime == null || now.difference(_lastHistorySaveTime!).inMinutes >= 2) {
          shouldSaveHistory = true;
        }
      }
    } else {
      // First point always saves
      shouldSaveHistory = true;
    }

    if (shouldSaveHistory) {
      if (!position.latitude.isFinite || !position.longitude.isFinite) {
        debugPrint('Skipping bad GPS data (NaN detected).');
        return;
      }
      debugPrint('Capturing point to local memory.');
      _lastHistorySaveTime = now;
      
      final Map<String, dynamic> locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': now.toUtc().millisecondsSinceEpoch,
        'local_time': DateFormat('hh:mm a').format(now),
        'country': 'Unknown',
        'address': 'Offline',
        'speed': position.speed,
        'accuracy': position.accuracy,
        'battery_level': batteryLevel,
        'is_charging': isCharging ? 1 : 0,
        'is_synced': 0,
      };
      
      await _dbService.insertLocation(locationData);
      _lastPosition = position;
    }

    // 6. Handle Syncs (Adaptive timer based on battery)
    await _checkAndPerformSyncs(username, uid, position, batteryLevel, isCharging);
  }

  Future<void> _checkAndPerformSyncs(String username, String uid, Position position, int batteryLevel, bool isCharging) async {
    final now = DateTime.now();

    // Live Update (Every 5 min)
    bool shouldLiveUpdate = false;
    if (_lastLiveUpdateTime == null || now.difference(_lastLiveUpdateTime!).inMinutes >= 5) {
      shouldLiveUpdate = true;
    }

    if (shouldLiveUpdate) {
      debugPrint('Syncing Live Update to Firebase: locations/$username/current');
      await _performLiveUpdate(username, position, batteryLevel, isCharging);
      _lastLiveUpdateTime = now;
    }

    // Adaptive Batch Upload Timer
    int batchIntervalMinutes = 15; // Healthy Battery -> Every 15 mins
    if (batteryLevel < 20 && !isCharging) {
      // Critical Battery -> pause sync completely
      debugPrint('Critical battery ($batteryLevel%). Pausing history batch upload to save power.');
      return; 
    } else if (batteryLevel <= 50 && !isCharging) {
      batchIntervalMinutes = 30; // Conserving Battery -> Every 30 mins
    }

    if (_lastBatchUploadTime == null || now.difference(_lastBatchUploadTime!).inMinutes >= batchIntervalMinutes) {
      debugPrint('Syncing History Batch (Interval: $batchIntervalMinutes mins)...');
      await _performBatchUpload(username);
      _lastBatchUploadTime = now;
    }
  }

  Future<void> _performLiveUpdate(String username, Position position, int batteryLevel, bool isCharging) async {
    try {
      final Map<String, dynamic> liveData = {
        'lat': position.latitude,
        'long': position.longitude,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'localTime': DateFormat('hh:mm a').format(DateTime.now()),
        'battery': batteryLevel,
        'isCharging': isCharging,
        'accuracy': position.accuracy,
        'speed': position.speed,
      };

      await _firebaseDb.ref('locations/$username/current').set(liveData);
      debugPrint('Firebase: Live Update Successful.');
    } catch (e) {
      debugPrint('Firebase Error (Live): $e');
    }
  }

  Future<void> _performBatchUpload(String username) async {
    try {
      final unsynced = await _dbService.getUnsyncedLocations();
      if (unsynced.isEmpty) {
        debugPrint('Batch Upload: No unsynced data found.');
        return;
      }

      final Map<String, dynamic> batchData = {};
      final List<int> idsToMark = [];

      for (var log in unsynced) {
        final String key = log['timestamp'].toString();
        batchData[key] = {
          'lat': log['latitude'],
          'long': log['longitude'],
          'localTime': log['local_time'],
          'speed': log['speed'],
          'accuracy': log['accuracy'],
          'battery': log['battery_level'],
          'isCharging': log['is_charging'] == 1,
        };
        idsToMark.add(log['id']);
      }

      await _firebaseDb.ref('locations/$username/history').update(batchData);
      await _dbService.deleteLocations(idsToMark);
      debugPrint('Batch Upload Successful: ${idsToMark.length} points synced and removed locally.');
    } catch (e) {
      debugPrint('Firebase Error (Batch): $e');
    }
  }

  Future<bool> _isSleepModeActive(SharedPreferences prefs) async {
    final bool sleepEnabled = prefs.getBool('sleep_mode_enabled') ?? true;
    if (!sleepEnabled) return false;

    final String? startTimeStr = prefs.getString('sleep_mode_start'); // Format: "HH:mm"
    final String? endTimeStr = prefs.getString('sleep_mode_end');
    
    if (startTimeStr == null || endTimeStr == null) return false;

    final now = DateTime.now();
    final startParts = startTimeStr.split(':');
    final endParts = endTimeStr.split(':');
    
    final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
    var endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));

    if (endTime.isBefore(startTime)) {
      // Handles ranges across midnight like 11 PM to 5 AM
      endTime = endTime.add(const Duration(days: 1));
    }

    // Also check if 'now' is before start but after end when range is across midnight
    var compareNow = now;
    if (now.isBefore(startTime) && now.isBefore(endTime.subtract(const Duration(days: 1)))) {
       compareNow = now.add(const Duration(days: 1));
    }

    return compareNow.isAfter(startTime) && compareNow.isBefore(endTime);
  }
}
