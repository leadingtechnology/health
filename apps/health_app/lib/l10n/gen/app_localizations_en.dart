// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Health Assistant';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navLogs => 'Logs';

  @override
  String get navCircle => 'Circle';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => 'Chinese (Simplified)';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get plansTitle => 'Plans';

  @override
  String get planFreeTitle => 'Free';

  @override
  String get planFreeSubtitle => 'Up to 3 asks per day';

  @override
  String get planStandardTitle => 'Standard';

  @override
  String get planStandardSubtitle => 'Unlimited usage and advanced insights';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProSubtitle => 'Unlimited + Realtime + Premium';

  @override
  String get modelBasic => 'Basic';

  @override
  String get modelEnhanced => 'Enhanced';

  @override
  String get modelRealtime => 'Realtime';

  @override
  String get quotaUnlimited => 'Unlimited';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Remaining $remaining/$total';
  }

  @override
  String get chatInputHint => 'Ask your health assistant…';

  @override
  String get send => 'Send';

  @override
  String get voiceHoldToTalk => 'Hold to talk';

  @override
  String get voiceReleaseToSend => 'Release to send';

  @override
  String get actionSetTask => 'Set as Task';

  @override
  String get actionExportPdf => 'Export PDF';

  @override
  String get actionShare => 'Share';

  @override
  String get paywallTitle => 'You\'ve reached today\'s limit';

  @override
  String get paywallBody =>
      'Free plan includes 3 asks per day. Upgrade for unlimited access.';

  @override
  String get paywallLater => 'Maybe later';

  @override
  String get paywallUpgrade => 'Upgrade';

  @override
  String get paywallFootnote => '* Usage resets every day';

  @override
  String get tasksEmpty => 'No tasks yet. Convert a suggestion into a task!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Due: $dateString';
  }

  @override
  String get taskEditTitle => 'New Task';

  @override
  String get taskTitleLabel => 'Title';

  @override
  String get taskTitleRequired => 'Required';

  @override
  String get taskDueLabel => 'Due';

  @override
  String get select => 'Select';

  @override
  String get taskNotesLabel => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get logsQuickActions => 'Quick actions';

  @override
  String get logsLike => 'Like';

  @override
  String get logsLikeNote => 'Tap to like helpful tips';

  @override
  String get stepsTitle => 'Steps';

  @override
  String get stepsNote => 'today';

  @override
  String get sleepTitle => 'Sleep';

  @override
  String get sleepNote => 'avg';

  @override
  String get bpTitle => 'Blood Pressure';

  @override
  String get bpNote => 'avg';

  @override
  String get hrTitle => 'Heart Rate';

  @override
  String get hrNote => 'resting';

  @override
  String get inviteSheetTitle => 'Family / Care circle';

  @override
  String get nameLabel => 'Name';

  @override
  String get relationLabel => 'Relation';

  @override
  String get sendInvite => 'Send invite';

  @override
  String sharedWithName(String name) {
    return 'Sent share to $name';
  }

  @override
  String get share => 'Share';

  @override
  String get readingPrivacyTitle => 'Reading & privacy';

  @override
  String get textSize => 'Text size';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyDesc => 'We respect your privacy.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDesc => 'Basic information about the app.';

  @override
  String get displayTitle => 'Display';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeElder => 'Large text';

  @override
  String get fontAutoNote => 'Font is set automatically by language.';

  @override
  String get taskAdded => 'Task added';

  @override
  String get exportPrepared => 'Preparing export…';

  @override
  String get sharePrepared => 'Preparing share…';

  @override
  String get welcomeMessage =>
      'Hi! I\'m your health assistant. Ask anything to get started.';

  @override
  String get sampleAdvice =>
      'Here are 3 tips for today:\n1) Walk 10 minutes in 4-2-4 pace.\n2) Drink a glass of water.\n3) Stretch your back and neck gently.';
}
