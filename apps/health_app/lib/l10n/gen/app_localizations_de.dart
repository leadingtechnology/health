// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Gesundheitsassistent';

  @override
  String get navAssistant => 'Assistent';

  @override
  String get navTasks => 'Aufgaben';

  @override
  String get navLogs => 'Protokolle';

  @override
  String get navCircle => 'Kreis';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageChineseSimplified => 'Chinesisch (Vereinfacht)';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get plansTitle => 'Pläne';

  @override
  String get planFreeTitle => 'Kostenlos';

  @override
  String get planFreeSubtitle => 'Bis zu 3 Anfragen pro Tag';

  @override
  String get planStandardTitle => 'Standard';

  @override
  String get planStandardSubtitle =>
      'Unbegrenzte Nutzung und erweiterte Einblicke';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProSubtitle => 'Unbegrenzt + Echtzeit + Premium';

  @override
  String get modelBasic => 'Basis';

  @override
  String get modelEnhanced => 'Erweitert';

  @override
  String get modelRealtime => 'Echtzeit';

  @override
  String get quotaUnlimited => 'Unbegrenzt';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Verbleibend $remaining/$total';
  }

  @override
  String get chatInputHint => 'Fragen Sie Ihren Gesundheitsassistenten…';

  @override
  String get send => 'Senden';

  @override
  String get voiceHoldToTalk => 'Zum Sprechen gedrückt halten';

  @override
  String get voiceReleaseToSend => 'Zum Senden loslassen';

  @override
  String get actionSetTask => 'Als Aufgabe setzen';

  @override
  String get actionExportPdf => 'PDF exportieren';

  @override
  String get actionShare => 'Teilen';

  @override
  String get paywallTitle => 'Sie haben das heutige Limit erreicht';

  @override
  String get paywallBody =>
      'Der kostenlose Plan beinhaltet 3 Anfragen pro Tag. Upgraden Sie für unbegrenzten Zugang.';

  @override
  String get paywallLater => 'Vielleicht später';

  @override
  String get paywallUpgrade => 'Upgraden';

  @override
  String get paywallFootnote => '* Nutzung wird täglich zurückgesetzt';

  @override
  String get tasksEmpty =>
      'Noch keine Aufgaben. Wandeln Sie einen Vorschlag in eine Aufgabe um!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Fällig: $dateString';
  }

  @override
  String get taskEditTitle => 'Neue Aufgabe';

  @override
  String get taskTitleLabel => 'Titel';

  @override
  String get taskTitleRequired => 'Erforderlich';

  @override
  String get taskDueLabel => 'Fällig';

  @override
  String get select => 'Auswählen';

  @override
  String get taskNotesLabel => 'Notizen';

  @override
  String get save => 'Speichern';

  @override
  String get logsQuickActions => 'Schnellaktionen';

  @override
  String get logsLike => 'Gefällt mir';

  @override
  String get logsLikeNote => 'Tippen Sie, um hilfreiche Tipps zu liken';

  @override
  String get stepsTitle => 'Schritte';

  @override
  String get stepsNote => 'heute';

  @override
  String get sleepTitle => 'Schlaf';

  @override
  String get sleepNote => 'Ø';

  @override
  String get bpTitle => 'Blutdruck';

  @override
  String get bpNote => 'Ø';

  @override
  String get hrTitle => 'Herzfrequenz';

  @override
  String get hrNote => 'Ruhe';

  @override
  String get inviteSheetTitle => 'Familie / Pflegekreis';

  @override
  String get nameLabel => 'Name';

  @override
  String get relationLabel => 'Beziehung';

  @override
  String get sendInvite => 'Einladung senden';

  @override
  String sharedWithName(String name) {
    return 'Geteilt mit $name';
  }

  @override
  String get share => 'Teilen';

  @override
  String get readingPrivacyTitle => 'Lesen & Datenschutz';

  @override
  String get textSize => 'Textgröße';

  @override
  String get privacyTitle => 'Datenschutz';

  @override
  String get privacyDesc => 'Wir respektieren Ihre Privatsphäre.';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutDesc => 'Grundlegende Informationen über die App.';

  @override
  String get displayTitle => 'Anzeige';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeElder => 'Großer Text';

  @override
  String get fontAutoNote =>
      'Schriftart wird automatisch nach Sprache eingestellt.';

  @override
  String get taskAdded => 'Aufgabe hinzugefügt';

  @override
  String get exportPrepared => 'Export wird vorbereitet…';

  @override
  String get sharePrepared => 'Teilen wird vorbereitet…';

  @override
  String get welcomeMessage =>
      'Hallo! Ich bin Ihr Gesundheitsassistent. Stellen Sie eine Frage, um zu beginnen.';

  @override
  String get sampleAdvice =>
      'Hier sind 3 Tipps für heute:\n1) Gehen Sie 10 Minuten im 4-2-4 Tempo.\n2) Trinken Sie ein Glas Wasser.\n3) Dehnen Sie sanft Ihren Rücken und Nacken.';
}
