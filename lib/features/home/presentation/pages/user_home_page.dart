import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import '../../../../core/config/app_config.dart';
import 'package:familypath/core/services/location_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../auth/services/auth_service.dart';
import '../widgets/optimization_guide_dialog.dart';
import 'webview_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with TickerProviderStateMixin {
  String _currentAddress = '📍 Fetching location...';
  String _lastUpdated = '--';
  bool _isLoading = false;

  late AnimationController _pulseController;
  final Map<String, String> _titleCache = {};
  late final DatabaseReference _dbRef;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConfig.firebaseDatabaseUrl,
    ).ref('videos/youtube');
    _refreshLocation();
    _checkBatteryOptimization();
  }

  Future<void> _checkBatteryOptimization() async {
    // Only show for tracked users
    if (AuthService().currentUserRole != 'user') return;

    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(seconds: 2));
    
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const OptimizationGuideDialog(),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<String> _getVideoTitle(String videoId) async {
    if (_titleCache.containsKey(videoId)) return _titleCache[videoId]!;

    try {
      final response = await http.get(Uri.parse(
          'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['title'] as String;
        _titleCache[videoId] = title;
        return title;
      }
    } catch (e) {
      debugPrint('Error fetching title for $videoId: $e');
    }
    return 'Hajj Guidance Video'; // Fallback
  }

  Future<void> _refreshLocation() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _currentAddress = '📍 Fetching location...';
    });

    final address = await LocationService().getCurrentAddress();

    if (mounted) {
      setState(() {
        _currentAddress = address;
        _isLoading = false;
        final now = DateTime.now();
        _lastUpdated = DateFormat('h:mm a').format(now);
      });
    }
  }

  void _openResource(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url, title: title),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w900, 
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  String _toBengaliNumbers(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }

  String _getBengaliHijriMonth(int month) {
    const months = [
      'মহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
      'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শাবান',
      'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ্জ'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final username = AuthService().currentUsername ?? 'Pilgrim';
    final isBengali = Localizations.localeOf(context).languageCode == 'bn';
    
    // Date Logic (Static)
    final now = DateTime.now();
    final englishDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    final hijriDate = HijriCalendar.now();
    
    // Localized Hijri Date String
    String hDay = isBengali ? _toBengaliNumbers(hijriDate.hDay.toString()) : hijriDate.hDay.toString();
    String hMonth = isBengali ? _getBengaliHijriMonth(hijriDate.hMonth) : hijriDate.longMonthName;
    String hYear = isBengali ? _toBengaliNumbers(hijriDate.hYear.toString()) : hijriDate.hYear.toString();
    String hSuffix = isBengali ? 'হিজরি' : 'AH';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FamilyPath'),
            Text(
              l10n.navHome,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            onPressed: _refreshLocation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLocation,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // PERSONALIZED WELCOME
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.welcomeBack},',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.4),
                    letterSpacing: 0.1,
                  ),
                ),
                Text(
                  username,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // DUAL DATE HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            englishDate,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('h:mm a').format(now),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "$hDay $hMonth",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$hYear $hSuffix",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PREMIUM INTEGRATED LOCATION CARD
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(color: Colors.black.withValues(alpha: 0.035)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ScaleTransition(
                            scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF43A047),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.currentLocation.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF43A047),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isLoading ? 'UPDATING' : 'LIVE',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.near_me_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentAddress,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.history_rounded, size: 14, color: Colors.black.withValues(alpha: 0.3)),
                                const SizedBox(width: 6),
                                Text(
                                  'Updated $_lastUpdated',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildSectionHeader(l10n.hajjAssistance),
            const SizedBox(height: 12),
            
            // HORIZONTAL CAROUSEL FOR ASSISTANCE
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildPremiumAssistanceCard(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: l10n.hajjGuide,
                    subtitle: 'Full Guidelines',
                    colors: [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                    onTap: () => _openResource(
                      context, 
                      'https://drive.google.com/file/d/1AxusnoTTaV-H7J_yY58i3hAbjPSxBX1u/view?usp=sharing', 
                      l10n.hajjGuide
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildPremiumAssistanceCard(
                    context,
                    icon: Icons.mosque_rounded,
                    title: l10n.dailyDua,
                    subtitle: 'Essential Prayers',
                    colors: [const Color(0xFFF57C00), const Color(0xFFFFB74D)],
                    onTap: () => _openResource(
                      context, 
                      'https://hajjessential.com.bd/featured_item/%E0%A6%89%E0%A6%AE%E0%A6%B0%E0%A6%BE%E0%A6%B9%E0%A6%B0-%E0%A6%B8%E0%A6%95%E0%A6%B2-%E0%A6%A6%E0%A7%8B%E0%A7%9F%E0%A6%BE/', 
                      l10n.dailyDua
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildPremiumAssistanceCard(
                    context,
                    icon: Icons.auto_stories_rounded,
                    title: l10n.readQuran,
                    subtitle: 'Bangla Translation',
                    colors: [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
                    onTap: () => _openResource(
                      context, 
                      'https://quran.com/bn', 
                      l10n.holyQuran
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildSectionHeader(l10n.videoTutorials),
            const SizedBox(height: 12),
            
            _buildVideoSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumAssistanceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return StreamBuilder(
      stream: _dbRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final String youtubeString = snapshot.data!.snapshot.value.toString();
        if (youtubeString.trim().isEmpty) {
          return const Center(child: Text('No videos available yet.'));
        }

        final List<String> videoIds = youtubeString
            .split(',')
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toList();

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videoIds.length,
          itemBuilder: (context, index) {
            return _buildYouTubeStyleCard(context, videoIds[index]);
          },
        );
      },
    );
  }

  Widget _buildYouTubeStyleCard(BuildContext context, String videoId) {
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    final videoUrl = 'https://www.youtube.com/watch?v=$videoId';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              url: videoUrl,
              title: _titleCache[videoId] ?? 'Video Guidance',
            ),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              thumbnailUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.play_circle_fill, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                  child: const Icon(Icons.mosque_rounded, size: 18, color: Colors.blueAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getVideoTitle(videoId),
                        builder: (context, snapshot) {
                          final title = snapshot.data ?? 'Loading title...';
                          return Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F0F0F),
                              height: 1.3,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'FamilyPath Guidance • Hajj Tutorials',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF606060),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, size: 18, color: Color(0xFF0F0F0F)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

