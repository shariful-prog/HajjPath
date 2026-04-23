import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/geo_utils.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import './history_screen.dart';

class UserListScreen extends StatefulWidget {
  final VoidCallback? onUserTap;
  const UserListScreen({super.key, this.onUserTap});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConfig.firebaseDatabaseUrl,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Main Content
          StreamBuilder(
            stream: db.ref('users').onValue,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final Map<dynamic, dynamic> usersMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              
              // Only filter by role
              final users = usersMap.entries.where((e) {
                final data = e.value as Map;
                return data['type'] == 'user';
              }).toList();

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noFamilyMembers,
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 100), // Reduced top padding
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10), // Reduced spacing
                itemBuilder: (context, index) {
                  final username = users[index].key as String;
                  final userData = users[index].value as Map;
                  
                  return _PremiumUserCard(
                    username: username,
                    fullName: userData['fullName'] ?? username,
                    profilePic: userData['profilePic'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(initialUser: username),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          // Glassmorphic Header with Search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'FamilyPath',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          ),
                          Text(
                            l10n.navUsers,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        child: const Icon(Icons.people_alt_rounded, size: 16, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumUserCard extends StatelessWidget {
  final String username;
  final String fullName;
  final String? profilePic;
  final VoidCallback onTap;

  const _PremiumUserCard({
    required this.username,
    required this.fullName,
    this.profilePic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConfig.firebaseDatabaseUrl,
    );

    return StreamBuilder(
      stream: db.ref('locations/$username/current').onValue,
      builder: (context, snapshot) {
        bool isOnline = false;
        String statusText = l10n.offlineStatus;
        int battery = 0;
        double? lat;
        double? lng;

        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;
          final timestamp = data['timestamp'] as int? ?? 0;
          battery = data['battery'] as int? ?? 0;
          lat = double.tryParse(data['lat']?.toString() ?? '');
          lng = double.tryParse(data['long']?.toString() ?? '');

          final lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final diff = DateTime.now().difference(lastSeen);

          if (diff.inMinutes < 10) {
            isOnline = true;
            statusText = l10n.activeNow;
          } else {
            statusText = DateFormat('h:mm a, MMM d').format(lastSeen);
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Avatar with Premium Glow Indicator
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isOnline 
                              ? [Colors.greenAccent, Colors.green] 
                              : [Colors.grey.shade300, Colors.grey.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                            backgroundImage: profilePic != null ? NetworkImage(getGoogleDriveDirectLink(profilePic!)) : null,
                            child: profilePic == null 
                              ? Text(fullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent))
                              : null,
                          ),
                        ),
                      ),
                      if (isOnline)
                         Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 4)],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700, 
                            fontSize: 16, 
                            letterSpacing: -0.4,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Real-time Address with cleaner font
                        if (lat != null && lng != null)
                          FutureBuilder<String>(
                            future: getAddressFromLatLng(lat, lng),
                            builder: (context, addrSnapshot) {
                              return Text(
                                addrSnapshot.data ?? l10n.fetchingLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[500], 
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          )
                        else
                          Text(l10n.locationNotAvailable, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        
                        const SizedBox(height: 6),
                        // Status Labels Row
                        Row(
                          children: [
                            _buildCompactBadge(
                              text: statusText,
                              color: isOnline ? Colors.green : Colors.grey,
                              isActive: isOnline,
                            ),
                            const SizedBox(width: 8),
                            if (battery > 0)
                              _buildCompactBadge(
                                text: '$battery%',
                                icon: battery < 20 ? Icons.battery_alert_rounded : Icons.battery_std_rounded,
                                color: battery < 20 ? Colors.red : Colors.blueGrey,
                                isBattery: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Navigation Indicator (Chevron only)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[300],
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactBadge({
    required String text,
    IconData? icon,
    required Color color,
    bool isActive = false,
    bool isBattery = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else if (isActive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

