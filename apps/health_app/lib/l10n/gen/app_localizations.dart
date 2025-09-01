import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Assistant'**
  String get appTitle;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get navAssistant;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get navLogs;

  /// No description provided for @navCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get navCircle;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageChineseSimplified;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// No description provided for @planFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFreeTitle;

  /// No description provided for @planFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 asks per day'**
  String get planFreeSubtitle;

  /// No description provided for @planStandardTitle.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get planStandardTitle;

  /// No description provided for @planStandardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited usage and advanced insights'**
  String get planStandardSubtitle;

  /// No description provided for @planProTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planProTitle;

  /// No description provided for @planProSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited + Realtime + Premium'**
  String get planProSubtitle;

  /// No description provided for @modelBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get modelBasic;

  /// No description provided for @modelEnhanced.
  ///
  /// In en, this message translates to:
  /// **'Enhanced'**
  String get modelEnhanced;

  /// No description provided for @modelRealtime.
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get modelRealtime;

  /// No description provided for @quotaUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get quotaUnlimited;

  /// No description provided for @quotaRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining {remaining}/{total}'**
  String quotaRemaining(int remaining, int total);

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your health assistant…'**
  String get chatInputHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @voiceHoldToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get voiceHoldToTalk;

  /// No description provided for @voiceReleaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Release to send'**
  String get voiceReleaseToSend;

  /// No description provided for @actionSetTask.
  ///
  /// In en, this message translates to:
  /// **'Set as Task'**
  String get actionSetTask;

  /// No description provided for @actionExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get actionExportPdf;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit'**
  String get paywallTitle;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'Free plan includes 3 asks per day. Upgrade for unlimited access.'**
  String get paywallBody;

  /// No description provided for @paywallLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get paywallLater;

  /// No description provided for @paywallUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get paywallUpgrade;

  /// No description provided for @paywallFootnote.
  ///
  /// In en, this message translates to:
  /// **'* Usage resets every day'**
  String get paywallFootnote;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Convert a suggestion into a task!'**
  String get tasksEmpty;

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueLabel(DateTime date);

  /// No description provided for @taskEditTitle.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get taskEditTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get taskTitleRequired;

  /// No description provided for @taskDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get taskDueLabel;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @taskNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get taskNotesLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @logsQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get logsQuickActions;

  /// No description provided for @logsLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get logsLike;

  /// No description provided for @logsLikeNote.
  ///
  /// In en, this message translates to:
  /// **'Tap to like helpful tips'**
  String get logsLikeNote;

  /// No description provided for @stepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsTitle;

  /// No description provided for @stepsNote.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get stepsNote;

  /// No description provided for @sleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepTitle;

  /// No description provided for @sleepNote.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get sleepNote;

  /// No description provided for @bpTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bpTitle;

  /// No description provided for @bpNote.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get bpNote;

  /// No description provided for @hrTitle.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get hrTitle;

  /// No description provided for @hrNote.
  ///
  /// In en, this message translates to:
  /// **'resting'**
  String get hrNote;

  /// No description provided for @inviteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Family / Care circle'**
  String get inviteSheetTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @relationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relationLabel;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get sendInvite;

  /// No description provided for @sharedWithName.
  ///
  /// In en, this message translates to:
  /// **'Sent share to {name}'**
  String sharedWithName(String name);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @readingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading & privacy'**
  String get readingPrivacyTitle;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyDesc.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy.'**
  String get privacyDesc;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Basic information about the app.'**
  String get aboutDesc;

  /// No description provided for @displayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displayTitle;

  /// No description provided for @modeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get modeNormal;

  /// No description provided for @modeElder.
  ///
  /// In en, this message translates to:
  /// **'Large text'**
  String get modeElder;

  /// No description provided for @fontAutoNote.
  ///
  /// In en, this message translates to:
  /// **'Font is set automatically by language.'**
  String get fontAutoNote;

  /// No description provided for @taskAdded.
  ///
  /// In en, this message translates to:
  /// **'Task added'**
  String get taskAdded;

  /// No description provided for @exportPrepared.
  ///
  /// In en, this message translates to:
  /// **'Preparing export…'**
  String get exportPrepared;

  /// No description provided for @sharePrepared.
  ///
  /// In en, this message translates to:
  /// **'Preparing share…'**
  String get sharePrepared;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your health assistant. Ask anything to get started.'**
  String get welcomeMessage;

  /// No description provided for @sampleAdvice.
  ///
  /// In en, this message translates to:
  /// **'Here are 3 tips for today:\n1) Walk 10 minutes in 4-2-4 pace.\n2) Drink a glass of water.\n3) Stretch your back and neck gently.'**
  String get sampleAdvice;
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
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
