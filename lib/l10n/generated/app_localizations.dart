import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FamilyPath'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get navJourney;

  /// No description provided for @navTranslator.
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get navTranslator;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsers;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @fetchingLabel.
  ///
  /// In en, this message translates to:
  /// **'Fetching address...'**
  String get fetchingLabel;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationNotAvailable;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'Tracking Active'**
  String get trackingActive;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY SOS'**
  String get emergencySos;

  /// No description provided for @hajjAssistance.
  ///
  /// In en, this message translates to:
  /// **'Hajj Assistance'**
  String get hajjAssistance;

  /// No description provided for @hajjGuide.
  ///
  /// In en, this message translates to:
  /// **'Hajj Guide'**
  String get hajjGuide;

  /// No description provided for @hajjRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey Roadmap'**
  String get hajjRoadmapTitle;

  /// No description provided for @hajjRoadmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide for all Hajj rituals and locations.'**
  String get hajjRoadmapDesc;

  /// No description provided for @translatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Translator'**
  String get translatorTitle;

  /// No description provided for @translatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Translate between Arabic and Bengali instantly.'**
  String get translatorDesc;

  /// No description provided for @videoTutorials.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorials'**
  String get videoTutorials;

  /// No description provided for @howToIhram.
  ///
  /// In en, this message translates to:
  /// **'How to wear Ihram'**
  String get howToIhram;

  /// No description provided for @tawafGuide.
  ///
  /// In en, this message translates to:
  /// **'Tawaf Procedures'**
  String get tawafGuide;

  /// No description provided for @minaSafety.
  ///
  /// In en, this message translates to:
  /// **'Mina Tent Guide'**
  String get minaSafety;

  /// No description provided for @holyQuran.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get holyQuran;

  /// No description provided for @readQuran.
  ///
  /// In en, this message translates to:
  /// **'Read Quran'**
  String get readQuran;

  /// No description provided for @bengaliTranslation.
  ///
  /// In en, this message translates to:
  /// **'Bengali Translation'**
  String get bengaliTranslation;

  /// No description provided for @dailyDua.
  ///
  /// In en, this message translates to:
  /// **'Daily Dua'**
  String get dailyDua;

  /// No description provided for @essentialPrayers.
  ///
  /// In en, this message translates to:
  /// **'Essential Hajj Prayers'**
  String get essentialPrayers;

  /// No description provided for @offlineTranslation.
  ///
  /// In en, this message translates to:
  /// **'Offline Translation'**
  String get offlineTranslation;

  /// No description provided for @offlineSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Setup is required for zero-internet support.'**
  String get offlineSetupRequired;

  /// No description provided for @initializedProgress.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% Initialized...'**
  String initializedProgress(String percentage);

  /// No description provided for @enableOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'ENABLE OFFLINE MODE'**
  String get enableOfflineMode;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(String error);

  /// No description provided for @speakBanglaTitle.
  ///
  /// In en, this message translates to:
  /// **'SPEAK BANGLA'**
  String get speakBanglaTitle;

  /// No description provided for @arabicTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'ARABIC TRANSLATION'**
  String get arabicTranslationTitle;

  /// No description provided for @tapMicHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic below and start speaking...'**
  String get tapMicHint;

  /// No description provided for @translationAppearHint.
  ///
  /// In en, this message translates to:
  /// **'Your translation will appear here...'**
  String get translationAppearHint;

  /// No description provided for @listenLabel.
  ///
  /// In en, this message translates to:
  /// **'LISTEN'**
  String get listenLabel;

  /// No description provided for @clearLabel.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get clearLabel;

  /// No description provided for @stopLabel.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get stopLabel;

  /// No description provided for @speakLabel.
  ///
  /// In en, this message translates to:
  /// **'SPEAK'**
  String get speakLabel;

  /// No description provided for @adminHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin History'**
  String get adminHistoryTitle;

  /// No description provided for @userOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Users Overview'**
  String get userOverviewTitle;

  /// No description provided for @noFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'No family members found'**
  String get noFamilyMembers;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active Now'**
  String get activeNow;

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineStatus;

  /// No description provided for @searchingUsers.
  ///
  /// In en, this message translates to:
  /// **'Searching for active users...'**
  String get searchingUsers;

  /// No description provided for @noUsersInDB.
  ///
  /// In en, this message translates to:
  /// **'No users found in database.'**
  String get noUsersInDB;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String activeCount(String count);

  /// No description provided for @centerOnMap.
  ///
  /// In en, this message translates to:
  /// **'CENTER ON MAP'**
  String get centerOnMap;

  /// No description provided for @showTrails.
  ///
  /// In en, this message translates to:
  /// **'Show Trails'**
  String get showTrails;

  /// No description provided for @invalidLocation.
  ///
  /// In en, this message translates to:
  /// **'Invalid location data for this user'**
  String get invalidLocation;

  /// No description provided for @recentMovements.
  ///
  /// In en, this message translates to:
  /// **'Recent Movements'**
  String get recentMovements;

  /// No description provided for @selectUserHint.
  ///
  /// In en, this message translates to:
  /// **'Select a family member to view history'**
  String get selectUserHint;

  /// No description provided for @noTravelData.
  ///
  /// In en, this message translates to:
  /// **'No travel data for this date'**
  String get noTravelData;

  /// No description provided for @distLabel.
  ///
  /// In en, this message translates to:
  /// **'Dist.'**
  String get distLabel;

  /// No description provided for @topLabel.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get topLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @startLoc.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLoc;

  /// No description provided for @endLoc.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLoc;

  /// No description provided for @styleVoyager.
  ///
  /// In en, this message translates to:
  /// **'Voyager'**
  String get styleVoyager;

  /// No description provided for @styleSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get styleSatellite;

  /// No description provided for @styleDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get styleDark;

  /// No description provided for @loginSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking & Safety Companion during Hajj'**
  String get loginSubTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @enterBothFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter both fields'**
  String get enterBothFields;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @locationTracking.
  ///
  /// In en, this message translates to:
  /// **'Location Tracking'**
  String get locationTracking;

  /// No description provided for @enableTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable Tracking'**
  String get enableTracking;

  /// No description provided for @allowGPSCollection.
  ///
  /// In en, this message translates to:
  /// **'Allow GPS background collection'**
  String get allowGPSCollection;

  /// No description provided for @sleepMode.
  ///
  /// In en, this message translates to:
  /// **'Sleep Mode'**
  String get sleepMode;

  /// No description provided for @sleepModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable tracking during specific hours'**
  String get sleepModeDesc;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @step1Day.
  ///
  /// In en, this message translates to:
  /// **'8th Dhul Hijjah (8 ذو الحجة)'**
  String get step1Day;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Miqat & Ihram (Miqat & Ihram)'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Ihram is the sacred state from which the Hajj pilgrimage begins.'**
  String get step1Desc;

  /// No description provided for @step1Loc.
  ///
  /// In en, this message translates to:
  /// **'Miqat'**
  String get step1Loc;

  /// No description provided for @step1Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ Perform full Ghusl (Sunnah)\n✅ Trim nails and groom accordingly\n✅ Apply perfume (before Ihram)\n✅ Men: Two pieces of white cloth\n✅ Women: Modest clothing (face uncovered)\n✅ 2 Rakats Nafil prayer\n✅ Intention: \"Labaik Hajjan\"\n✅ Begin reciting the Talbiyah\n❌ Do not cut hair or nails\n❌ Hunting/Quarreling prohibited\n❌ Men: No stitched clothes or head covering'**
  String get step1Tasks;

  /// No description provided for @step2Day.
  ///
  /// In en, this message translates to:
  /// **'8th Dhul Hijjah (8 ذو الحجة)'**
  String get step2Day;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Stay in Mina (Yawm at-Tarwiyah)'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'This is the day of preparation — \"يوم التروية\".'**
  String get step2Desc;

  /// No description provided for @step2Loc.
  ///
  /// In en, this message translates to:
  /// **'Mina'**
  String get step2Loc;

  /// No description provided for @step2Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ Move to your assigned tent\n✅ Dhuhr prayer (2 Rakats - Qasr)\n✅ Asr prayer (2 Rakats - Qasr)\n✅ Maghrib prayer (3 Rakats)\n✅ Isha prayer (2 Rakats - Qasr)\n✅ Fajr prayer (2 Rakats)\n✅ Frequent Talbiyah & Dhikr\n⚠️ Save your tent number/location\n⚠️ Stay within your group'**
  String get step2Tasks;

  /// No description provided for @step3Day.
  ///
  /// In en, this message translates to:
  /// **'9th Dhul Hijjah (9 ذو الحجة)'**
  String get step3Day;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Day of Arafah'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'👉 \"Hajj is Arafah\" — The core pillar. Depart from Mina after Sunrise.'**
  String get step3Desc;

  /// No description provided for @step3Loc.
  ///
  /// In en, this message translates to:
  /// **'Arafah'**
  String get step3Loc;

  /// No description provided for @step3Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ Dhuhr + Asr (Combined & Shortened)\n✅ Stay in the plain of Arafah (Wuquf)\n✅ Sincere Dua with tears\n✅ Repentance for past sins\n✅ Frequent Istighfar & Durood\n⚠️ Must stay until Sunset'**
  String get step3Tasks;

  /// No description provided for @step4Day.
  ///
  /// In en, this message translates to:
  /// **'9th Night → 10th Dhul Hijjah'**
  String get step4Day;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Muzdalifah Night'**
  String get step4Title;

  /// No description provided for @step4Desc.
  ///
  /// In en, this message translates to:
  /// **'Staying under the stars — a critical step. Depart from Arafah after Sunset.'**
  String get step4Desc;

  /// No description provided for @step4Loc.
  ///
  /// In en, this message translates to:
  /// **'Muzdalifah'**
  String get step4Loc;

  /// No description provided for @step4Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ Maghrib + Isha (Combined)\n✅ Overnight stay in the open area\n✅ Collect pebbles (49 to 70 pieces)\n✅ Perform Fajr prayer & Dua\n⚠️ Depart for Mina before Sunrise'**
  String get step4Tasks;

  /// No description provided for @step5Day.
  ///
  /// In en, this message translates to:
  /// **'10th Dhul Hijjah (10 ذو الحجة)'**
  String get step5Day;

  /// No description provided for @step5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Day of Sacrifice (Yawm an-Nahr)'**
  String get step5Title;

  /// No description provided for @step5Desc.
  ///
  /// In en, this message translates to:
  /// **'The busiest day — 4 major acts to complete.'**
  String get step5Desc;

  /// No description provided for @step5Loc.
  ///
  /// In en, this message translates to:
  /// **'Mina'**
  String get step5Loc;

  /// No description provided for @step5Tasks.
  ///
  /// In en, this message translates to:
  /// **'🪨 Stone the Great Jamarat (7 pebbles)\n🐐 Complete the Sacrifice (Qurbani)\n✂️ Shave or trim hair (Tahallul)\n👕 Remove Ihram (Release from restrictions)'**
  String get step5Tasks;

  /// No description provided for @step6Day.
  ///
  /// In en, this message translates to:
  /// **'10th Dhul Hijjah or later'**
  String get step6Day;

  /// No description provided for @step6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Tawaf al-Ifadah'**
  String get step6Title;

  /// No description provided for @step6Desc.
  ///
  /// In en, this message translates to:
  /// **'👉 This is an obligatory pillar — Hajj is incomplete without it.'**
  String get step6Desc;

  /// No description provided for @step6Loc.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get step6Loc;

  /// No description provided for @step6Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ 7 circuits of Tawaf at Kaaba\n✅ 2 Rakats at Maqam Ibrahim\n✅ Complete Sa’i between Safa & Marwa\n✅ Return to Mina for overnight stay'**
  String get step6Tasks;

  /// No description provided for @step7Day.
  ///
  /// In en, this message translates to:
  /// **'11th–12th Dhul Hijjah'**
  String get step7Day;

  /// No description provided for @step7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Days of Tashreeq'**
  String get step7Title;

  /// No description provided for @step7Desc.
  ///
  /// In en, this message translates to:
  /// **'The days of stoning. Rituals begin after Dhuhr each day.'**
  String get step7Desc;

  /// No description provided for @step7Loc.
  ///
  /// In en, this message translates to:
  /// **'Mina'**
  String get step7Loc;

  /// No description provided for @step7Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ Small Jamarat (7 pebbles)\n✅ Middle Jamarat (7 pebbles)\n✅ Great Jamarat (7 pebbles)\n✅ Increased Dhikr & Prayers\n⚠️ Depart Mina before Sunset on the 12th'**
  String get step7Tasks;

  /// No description provided for @step8Day.
  ///
  /// In en, this message translates to:
  /// **'Before departing Makkah'**
  String get step8Day;

  /// No description provided for @step8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Farewell Tawaf (Tawaf al-Wida)'**
  String get step8Title;

  /// No description provided for @step8Desc.
  ///
  /// In en, this message translates to:
  /// **'Final Departure — A deeply emotional step. This is Wajib (mandatory).'**
  String get step8Desc;

  /// No description provided for @step8Loc.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get step8Loc;

  /// No description provided for @step8Tasks.
  ///
  /// In en, this message translates to:
  /// **'✅ 7 circuits of Farewell Tawaf\n✅ Sincere Dua for acceptance\n✅ Farewell bid to the Holy Kaaba'**
  String get step8Tasks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
