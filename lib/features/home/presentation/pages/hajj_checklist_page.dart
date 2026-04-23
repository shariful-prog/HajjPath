import 'package:flutter/material.dart';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class HajjChecklistPage extends StatelessWidget {
  const HajjChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<JourneyStep> steps = [
      JourneyStep(
        day: l10n.step1Day,
        title: l10n.step1Title,
        description: l10n.step1Desc,
        icon: Icons.explore_rounded,
        location: l10n.step1Loc,
        subTasks: l10n.step1Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step2Day,
        title: l10n.step2Title,
        description: l10n.step2Desc,
        icon: Icons.holiday_village_rounded,
        location: l10n.step2Loc,
        subTasks: l10n.step2Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step3Day,
        title: l10n.step3Title,
        description: l10n.step3Desc,
        icon: Icons.landscape_rounded,
        location: l10n.step3Loc,
        subTasks: l10n.step3Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step4Day,
        title: l10n.step4Title,
        description: l10n.step4Desc,
        icon: Icons.nightlight_round,
        location: l10n.step4Loc,
        subTasks: l10n.step4Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step5Day,
        title: l10n.step5Title,
        description: l10n.step5Desc,
        icon: Icons.adjust_rounded,
        location: l10n.step5Loc,
        subTasks: l10n.step5Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step6Day,
        title: l10n.step6Title,
        description: l10n.step6Desc,
        icon: Icons.mosque_rounded,
        location: l10n.step6Loc,
        subTasks: l10n.step6Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step7Day,
        title: l10n.step7Title,
        description: l10n.step7Desc,
        icon: Icons.join_full_rounded,
        location: l10n.step7Loc,
        subTasks: l10n.step7Tasks.split('\n'),
      ),
      JourneyStep(
        day: l10n.step8Day,
        title: l10n.step8Title,
        description: l10n.step8Desc,
        icon: Icons.login_rounded,
        location: l10n.step8Loc,
        subTasks: l10n.step8Tasks.split('\n'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FamilyPath'),
            Text(
              l10n.navJourney,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.green.shade50.withOpacity(0.2)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return _buildJourneyNode(
              context,
              steps[index],
              index == 0,
              index == steps.length - 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildJourneyNode(BuildContext context, JourneyStep step, bool isFirst, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isFirst ? Colors.transparent : const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E7D32), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Icon(step.icon, color: const Color(0xFF2E7D32), size: 26),
                ),
              ),
              Expanded(
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        isLast ? Colors.transparent : const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Step content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  step.day.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E7D32),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Text(
                                step.location,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B5E20),
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.grey.shade100,
                    ),

                    // Tasks Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        children: step.subTasks.map((task) => _buildTaskItem(task)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskText) {
    // Determine type and clean text
    IconData icon = Icons.radio_button_unchecked_rounded;
    Color color = Colors.grey.shade300;
    Color textColor = const Color(0xFF424242);
    FontWeight fontWeight = FontWeight.w500;

    String cleanText = taskText.trim();
    if (cleanText.startsWith('✅')) {
      icon = Icons.check_circle_rounded;
      color = const Color(0xFF43A047);
      cleanText = cleanText.replaceFirst('✅', '').trim();
    } else if (cleanText.startsWith('❌')) {
      icon = Icons.cancel_rounded;
      color = const Color(0xFFE53935);
      textColor = Colors.grey.shade500;
      fontWeight = FontWeight.w400;
      cleanText = cleanText.replaceFirst('❌', '').trim();
    } else if (cleanText.startsWith('⚠️')) {
      icon = Icons.info_outline_rounded;
      color = const Color(0xFFF9A825);
      cleanText = cleanText.replaceFirst('⚠️', '').trim();
    } else if (cleanText.startsWith('🪨')) {
      icon = Icons.diamond_rounded;
      color = Colors.blueGrey;
      cleanText = cleanText.replaceFirst('🪨', '').trim();
    } else if (cleanText.startsWith('🐐')) {
      icon = Icons.pets_rounded;
      color = Colors.brown;
      cleanText = cleanText.replaceFirst('🐐', '').trim();
    } else if (cleanText.startsWith('✂️')) {
      icon = Icons.content_cut_rounded;
      color = Colors.indigo;
      cleanText = cleanText.replaceFirst('✂️', '').trim();
    } else if (cleanText.startsWith('👕')) {
      icon = Icons.checkroom_rounded;
      color = Colors.teal;
      cleanText = cleanText.replaceFirst('👕', '').trim();
    }

    // Special prefixing for labels like "প্রতিদিন" or "🕌"
    if (cleanText.startsWith('প্রতিদিন')) {
       fontWeight = FontWeight.w800;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              cleanText,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                height: 1.4,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JourneyStep {
  final String day;
  final String title;
  final String description;
  final IconData icon;
  final String location;
  final List<String> subTasks;

  JourneyStep({
    required this.day,
    required this.title,
    required this.description,
    required this.icon,
    required this.location,
    required this.subTasks,
  });
}

