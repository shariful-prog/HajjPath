import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:familypath/features/auth/services/auth_service.dart';
import 'package:familypath/core/services/locale_service.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:familypath/features/auth/presentation/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isTrackingEnabled = true;
  bool _isSleepModeEnabled = true;
  String _sleepStartTime = '23:00';
  String _sleepEndTime = '05:00';
  bool _isUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTrackingEnabled = prefs.getBool('tracking_enabled') ?? true;
      _isSleepModeEnabled = prefs.getBool('sleep_mode_enabled') ?? true;
      _sleepStartTime = prefs.getString('sleep_mode_start') ?? '23:00';
      _sleepEndTime = prefs.getString('sleep_mode_end') ?? '05:00';
      _isUser = AuthService().currentUserRole == 'user';
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final currentTime = isStart ? _sleepStartTime : _sleepEndTime;
    final parts = currentTime.split(':');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _sleepStartTime = formattedTime;
          _saveSetting('sleep_mode_start', _sleepStartTime);
        } else {
          _sleepEndTime = formattedTime;
          _saveSetting('sleep_mode_end', _sleepEndTime);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FamilyPath'),
            Text(
              l10n.navSettings,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          _buildSectionHeader(l10n.general),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: l10n.profileSettings,
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none,
              title: l10n.pushNotifications,
              onTap: () {},
            ),
            _buildLanguageItem(l10n),
          ]),
          
          if (_isUser) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.locationTracking),
            _buildSettingsCard([
              SwitchListTile(
                secondary: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor),
                title: Text(l10n.enableTracking),
                subtitle: Text(l10n.allowGPSCollection),
                value: _isTrackingEnabled,
                onChanged: (val) {
                  setState(() => _isTrackingEnabled = val);
                  _saveSetting('tracking_enabled', val);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(Icons.bedtime_outlined, color: Theme.of(context).primaryColor),
                title: Text(l10n.sleepMode),
                subtitle: Text(l10n.sleepModeDesc),
                value: _isSleepModeEnabled,
                onChanged: (val) {
                  setState(() => _isSleepModeEnabled = val);
                  _saveSetting('sleep_mode_enabled', val);
                },
              ),
              if (_isSleepModeEnabled) ...[
                ListTile(
                  leading: const SizedBox(width: 40),
                  title: Text(l10n.startTime),
                  trailing: Text(_sleepStartTime, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  onTap: () => _selectTime(context, true),
                ),
                ListTile(
                  leading: const SizedBox(width: 40),
                  title: Text(l10n.endTime),
                  trailing: Text(_sleepEndTime, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  onTap: () => _selectTime(context, false),
                ),
              ],
            ]),
          ],

          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout.toUpperCase()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${l10n.version} 1.0.0',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(AppLocalizations l10n) {
    return ListTile(
      leading: Icon(Icons.translate_rounded, color: Theme.of(context).primaryColor),
      title: Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: ValueListenableBuilder<Locale>(
        valueListenable: LocaleService().localeNotifier,
        builder: (context, locale, _) {
          return DropdownButton<String>(
            value: locale.languageCode,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 24),
            items: [
              DropdownMenuItem(value: 'en', child: Text(l10n.english)),
              DropdownMenuItem(value: 'bn', child: Text(l10n.bengali)),
            ],
            onChanged: (val) {
              if (val != null) {
                LocaleService().changeLocale(val);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
