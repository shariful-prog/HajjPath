import 'package:flutter/material.dart';
import 'package:familypath/core/theme/app_theme.dart';
import 'package:familypath/core/services/locale_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'package:familypath/features/auth/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FamilyPathApp());
}

class FamilyPathApp extends StatelessWidget {
  const FamilyPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService().localeNotifier,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HajjPath',
          theme: AppTheme.lightTheme,
          locale: currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('bn'),
            Locale('en'),
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
