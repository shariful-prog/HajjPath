import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:familypath/features/auth/services/auth_service.dart';
import 'package:familypath/core/services/background_service.dart';
import 'package:familypath/core/services/locale_service.dart';
import 'package:familypath/features/navigation/main_navigation.dart';
import 'package:familypath/features/auth/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isInitStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_isInitStarted) return;
    _isInitStarted = true;

    final startTime = DateTime.now();

    try {
      // Initialize Firebase first because AuthService depends on it
      await Firebase.initializeApp();
      
      // Parallel Initialization for speed
      await Future.wait([
        AuthService().init(),
        LocaleService().init(),
        BackgroundService.requestPermissions(),
      ]);

      // Initialize background service (important for location)
      try {
        await BackgroundService.initializeService();
      } catch (e) {
        debugPrint('Background Service Init Error: $e');
      }

      // Ensure splash lasts at least 2 seconds for branding impact
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 2000) {
        await Future.delayed(Duration(milliseconds: 2000 - elapsed.inMilliseconds));
      }

      if (mounted) {
        _navigateToNext();
      }
    } catch (e) {
      debugPrint('Initialization Error: $e');
      // Even if error, try to move to login after some time
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _navigateToNext();
    }
  }

  void _navigateToNext() {
    final bool authenticated = AuthService().isAuthenticated;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => authenticated 
          ? const MainNavigation() 
          : const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Emerald
              Color(0xFF1B5E20), // Dark Green
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'FamilyPath',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 60,
              child: Column(
                children: [
                  Text(
                    'Your Secure Family Journey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 40,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
