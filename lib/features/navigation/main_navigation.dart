import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import '../home/presentation/pages/user_home_page.dart';
import '../home/presentation/pages/admin_home_page.dart';
import '../settings/presentation/pages/settings_page.dart';
import '../admin/presentation/pages/history_screen.dart';
import '../admin/presentation/pages/user_list_screen.dart';
import '../home/presentation/pages/translator_page.dart';
import '../home/presentation/pages/hajj_checklist_page.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService().currentUserRole == 'admin';
    final l10n = AppLocalizations.of(context)!;
    
    // Define pages for each role
    final List<Widget> pages = isAdmin
        ? [
            const AdminHomePage(),
            const HistoryScreen(),
            UserListScreen(onUserTap: () => _changeTab(0)),
            const SettingsPage(),
          ]
        : [
            const UserHomePage(),
            const HajjChecklistPage(),
            const TranslatorPage(),
            const SettingsPage(),
          ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: isAdmin
            ? [
                NavigationDestination(
                  icon: const Icon(Icons.map_outlined),
                  selectedIcon: const Icon(Icons.map),
                  label: l10n.navMap,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.history),
                  selectedIcon: const Icon(Icons.history_toggle_off),
                  label: l10n.navHistory,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: l10n.navUsers,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l10n.navSettings,
                ),
              ]
            : [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.checklist_rtl_outlined),
                  selectedIcon: const Icon(Icons.checklist_rtl_rounded),
                  label: l10n.navJourney,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.translate_rounded),
                  selectedIcon: const Icon(Icons.translate),
                  label: l10n.navTranslator,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l10n.navSettings,
                ),
              ],
      ),
    );
  }
}

