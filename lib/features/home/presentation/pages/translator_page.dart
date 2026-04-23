import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'package:familypath/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> with SingleTickerProviderStateMixin {
  // Engines
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late OnDeviceTranslator _translator;
  final _modelManager = OnDeviceTranslatorModelManager();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // State
  bool _isSpeechInitialized = false;
  bool _isListening = false;
  bool _isModelsDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  
  String _lastWords = '';
  String _translatedText = '';
  
  @override
  void initState() {
    super.initState();
    _checkModels();
    _initSTT();
    _initTranslator();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.bengali,
      targetLanguage: TranslateLanguage.arabic,
    );
  }

  Future<void> _checkModels() async {
    final bnDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.bengali.bcpCode);
    final arDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.arabic.bcpCode);
    
    if (mounted) {
      setState(() {
        _isModelsDownloaded = bnDownloaded && arDownloaded;
      });
    }
  }

  Future<void> _downloadModels() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.1;
    });

    try {
      await _modelManager.downloadModel(TranslateLanguage.bengali.bcpCode);
      setState(() => _downloadProgress = 0.5);
      await _modelManager.downloadModel(TranslateLanguage.arabic.bcpCode);
      setState(() => _downloadProgress = 1.0);
      _checkModels();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.downloadFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _initSTT() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) {
      setState(() => _isSpeechInitialized = available);
    }
  }

  void _startListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    if (_isSpeechInitialized && !_isListening) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() => _lastWords = result.recognizedWords);
          if (result.finalResult) _translate();
        },
        localeId: 'bn_BD',
        pauseFor: const Duration(seconds: 5),
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _translate() async {
    if (_lastWords.isEmpty) return;
    final translation = await _translator.translateText(_lastWords);
    if (mounted) {
      setState(() {
        _translatedText = translation;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _speakArabic();
      });
    }
  }

  Future<void> _speakArabic() async {
    if (_translatedText.isEmpty) return;
    await _flutterTts.setLanguage("ar");
    await _flutterTts.speak(_translatedText);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechToText.stop();
    _translator.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FamilyPath'),
            Text(
              l10n.navTranslator,
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
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
          ),
        ),
        child: !_isModelsDownloaded ? _buildDownloadView(l10n) : _buildTranslatorView(l10n),
      ),
    );
  }

  Widget _buildDownloadView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_download_rounded, size: 64, color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.offlineTranslation,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.offlineSetupRequired,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 15),
            ),
            const SizedBox(height: 48),
            if (_isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.initializedProgress((_downloadProgress * 100).toInt().toString()), style: const TextStyle(fontWeight: FontWeight.bold)),
            ] else 
              ElevatedButton.icon(
                onPressed: _downloadModels,
                icon: const Icon(Icons.bolt_rounded),
                label: Text(l10n.enableOfflineMode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size.fromHeight(64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: Colors.green.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatorView(AppLocalizations l10n) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildPremiumCard(
            title: l10n.speakBanglaTitle,
            content: _lastWords.isEmpty ? l10n.tapMicHint : _lastWords,
            isActive: _isListening,
            color: Colors.blue.shade700,
            icon: Icons.graphic_eq_rounded,
            isHint: _lastWords.isEmpty,
          ),
          const SizedBox(height: 24),
          _buildPremiumCard(
            title: l10n.arabicTranslationTitle,
            content: _translatedText.isEmpty ? l10n.translationAppearHint : _translatedText,
            isActive: false,
            color: const Color(0xFF2E7D32),
            icon: Icons.translate_rounded,
            isArabic: true,
            isHint: _translatedText.isEmpty,
          ),
          const SizedBox(height: 48),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                onPressed: _translatedText.isNotEmpty ? _speakArabic : null,
                icon: Icons.volume_up_rounded,
                label: l10n.listenLabel,
                color: const Color(0xFF2E7D32),
                size: 80,
              ),
              
              _buildMicButton(l10n),

              _buildControlButton(
                onPressed: () => setState(() { _lastWords = ''; _translatedText = ''; }),
                icon: Icons.refresh_rounded,
                label: l10n.clearLabel,
                color: Colors.redAccent,
                size: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _isListening ? Colors.red : Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isListening ? Colors.red : Theme.of(context).primaryColor).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: _isListening ? 10 : 0,
            )
          ],
        ),
        child: Column(
          children: [
             Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 40),
             const SizedBox(height: 8),
             Text(
               _isListening ? l10n.stopLabel : l10n.speakLabel, 
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required double size,
  }) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: onPressed == null ? Colors.grey.shade300 : color, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required String content,
    required bool isActive,
    required Color color,
    required IconData icon,
    bool isArabic = false,
    bool isHint = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isActive ? color : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
                    Icon(icon, color: color.withOpacity(0.3), size: 24),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(minHeight: 120),
                  child: Text(
                    content,
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontSize: isArabic ? 28 : 18,
                      height: 1.5,
                      fontWeight: isArabic ? FontWeight.w500 : FontWeight.w600,
                      color: isHint ? Colors.black26 : Colors.black87,
                    ),
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

