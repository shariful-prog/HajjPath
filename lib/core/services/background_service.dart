import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'tracking_service.dart';
import 'database_service.dart';

class BackgroundService {
  static const String notificationChannelId = 'location_tracking_channel_v2';
  static const int notificationId = 888;

  static Future<void> requestPermissions() async {
    // Request notification permission (Android 13+)
    await Permission.notification.request();
    
    // Request location permissions
    await Permission.location.request();
    await Permission.locationAlways.request();

    // Request battery optimization exemption
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Configure the notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Location Tracking',
      description: 'Maintains background location tracking',
      importance: Importance.low, // Low importance prevents sound and vibration on update
      playSound: false,
      enableVibration: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStartBackground,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'FamilyPath',
        initialNotificationContent: 'Location Security Active',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStartBackground,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStartBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  // IMPORTANT: Firebase must be initialized in this background isolate!
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  
  // Check if user is 'user' role
  final String? role = prefs.getString('user_role');
  final String? username = prefs.getString('user_name');
  final String? firebaseUid = prefs.getString('firebase_uid');

  debugPrint('Background Service Started. User: $username, Role: $role, UID: $firebaseUid');

  if (role != 'user' || username == null || firebaseUid == null) {
    debugPrint('Background Service: Stopping itself (Not a tracked user or missing credentials).');
    service.stopSelf();
    return;
  }

  // Force an immediate tick on startup
  _performTick(service, prefs, username, firebaseUid);

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    _performTick(service, prefs, username, firebaseUid);
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

Future<void> _performTick(
  ServiceInstance service, 
  SharedPreferences prefs, 
  String username, 
  String firebaseUid
) async {
  // Check if tracking is still enabled in prefs
  final bool trackingEnabled = prefs.getBool('tracking_enabled') ?? true;
  if (!trackingEnabled) return;

  // Run Tracking Logic
  try {
    final dbService = DatabaseService();
    await TrackingService().processTrackingTick(username, firebaseUid);

    // Fetch the unsynced count to update UI/Notification
    final unsynced = await dbService.getUnsyncedLocations();
    
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "FamilyPath", 
        content: "Location sync is running",
      );
    }
    
    // Also broadcast to foreground app
    service.invoke('syncUpdate', {
      'count': unsynced.length,
      'lastSync': DateFormat('hh:mm a').format(DateTime.now()),
    });
  } catch (e) {
    debugPrint('Tick Error: $e');
  }
}
