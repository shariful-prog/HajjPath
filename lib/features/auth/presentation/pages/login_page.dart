import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../../../core/services/background_service.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';

import 'package:familypath/features/navigation/main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _errorMessage = l10n.enterBothFields);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final error = await AuthService().login(username, password);

      if (mounted) {
        if (error == null) {
          // Attempt to start background service, log if fails but proceed
          try {
            await BackgroundService.initializeService();
          } catch (e) {
            debugPrint('Background Service init failed: $e');
          }
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "An unexpected error occurred.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist Branding
                const Icon(
                  Icons.mosque,
                  size: 64,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginSubTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 64),

                // Minimalist Form (No Box/Card)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: l10n.username,
                        filled: false,
                        contentPadding: EdgeInsets.only(bottom: 8, top: 12),
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                        ),
                        floatingLabelStyle: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        filled: false,
                        contentPadding: EdgeInsets.only(bottom: 8, top: 12),
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                        ),
                        floatingLabelStyle: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Action Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100), // Pill shaped
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ) 
                        : Text(l10n.loginButton),
                    ),
                  ],
                ),
                
                const SizedBox(height: 64),
                Text(
                  'Powered by Techgic',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black26,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.forgotPassword,
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

