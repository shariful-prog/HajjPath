import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../core/services/location_service.dart';
import '../../../core/config/app_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final FirebaseDatabase _db;
  late final FirebaseAuth _auth;
  late final SharedPreferences _prefs;
  late final LocationService _locationService;

  String? _currentUserRole;
  String? _currentUsername;
  
  String? get currentUserRole => _currentUserRole;
  String? get currentUsername => _currentUsername;
  String? get firebaseUid => _auth.currentUser?.uid;
  bool get isAuthenticated => _currentUserRole != null && _auth.currentUser != null;

  Future<void> init() async {
    _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConfig.firebaseDatabaseUrl,
    );
    _auth = FirebaseAuth.instance;
    _prefs = await SharedPreferences.getInstance();
    _locationService = LocationService();
    
    // Load persisted session
    _currentUserRole = _prefs.getString('user_role');
    _currentUsername = _prefs.getString('user_name');

    // ALWAYS ensure some form of Auth session exists for database permissions
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } catch (e) {
        // If we fail here, we might be offline, which is fine for now
      }
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      // 1. Ensure we have an active Auth session before reading
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      final snapshot = await _db.ref('users/$username').get();
      
      if (!snapshot.exists) {
        return 'User not found';
      }

      final userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
      
      if (userData['password'].toString() == password) {
        // 1. Sign in to Firebase Auth Anonymously for a secure UID
        final userCredential = await _auth.signInAnonymously();
        final String uid = userCredential.user!.uid;

        _currentUserRole = userData['type'];
        _currentUsername = username;

        // 2. Persist session
        await _prefs.setString('user_role', _currentUserRole!);
        await _prefs.setString('user_name', _currentUsername!);
        await _prefs.setString('firebase_uid', uid);

        // 3. Save initial login point strictly to "current" location
        try {
          final position = await _locationService.getCurrentPosition();
          final batteryLevel = await Battery().batteryLevel;
          final batteryState = await Battery().batteryState;
          
          final Map<String, dynamic> liveData = {
            'lat': position.latitude,
            'long': position.longitude,
            'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
            'localTime': DateFormat('hh:mm a').format(DateTime.now()),
            'battery': batteryLevel,
            'isCharging': batteryState == BatteryState.charging,
            'accuracy': position.accuracy,
            'speed': position.speed,
          };

          await _db.ref('locations/$username/current').set(liveData);
        } catch (e) {
          debugPrint('Initial Location sync failed: $e');
        }

        return null; // Success
      } else {
        return 'Incorrect password';
      }
    } catch (e) {
      return 'Connection error: ${e.toString()}';
    }
  }

  Future<void> logout() async {
    _currentUserRole = null;
    _currentUsername = null;
    await _prefs.remove('user_role');
    await _prefs.remove('user_name');
    await _auth.signOut();
  }
}
