// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Assistant Santé';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navTasks => 'Tâches';

  @override
  String get navLogs => 'Journaux';

  @override
  String get navCircle => 'Cercle';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Système par défaut';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageChineseSimplified => 'Chinois (Simplifié)';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get plansTitle => 'Plans';

  @override
  String get planFreeTitle => 'Gratuit';

  @override
  String get planFreeSubtitle => 'Jusqu\'à 3 demandes par jour';

  @override
  String get planStandardTitle => 'Standard';

  @override
  String get planStandardSubtitle =>
      'Utilisation illimitée et analyses avancées';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProSubtitle => 'Illimité + Temps réel + Premium';

  @override
  String get modelBasic => 'Basique';

  @override
  String get modelEnhanced => 'Amélioré';

  @override
  String get modelRealtime => 'Temps réel';

  @override
  String get quotaUnlimited => 'Illimité';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Restant $remaining/$total';
  }

  @override
  String get chatInputHint => 'Demandez à votre assistant santé…';

  @override
  String get send => 'Envoyer';

  @override
  String get voiceHoldToTalk => 'Maintenez pour parler';

  @override
  String get voiceReleaseToSend => 'Relâchez pour envoyer';

  @override
  String get actionSetTask => 'Définir comme tâche';

  @override
  String get actionExportPdf => 'Exporter PDF';

  @override
  String get actionShare => 'Partager';

  @override
  String get paywallTitle => 'Vous avez atteint la limite d\'aujourd\'hui';

  @override
  String get paywallBody =>
      'Le plan gratuit inclut 3 demandes par jour. Mettez à niveau pour un accès illimité.';

  @override
  String get paywallLater => 'Peut-être plus tard';

  @override
  String get paywallUpgrade => 'Mettre à niveau';

  @override
  String get paywallFootnote => '* L\'utilisation se remet à zéro chaque jour';

  @override
  String get tasksEmpty =>
      'Aucune tâche pour le moment. Convertissez une suggestion en tâche !';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Échéance : $dateString';
  }

  @override
  String get taskEditTitle => 'Nouvelle tâche';

  @override
  String get taskTitleLabel => 'Titre';

  @override
  String get taskTitleRequired => 'Requis';

  @override
  String get taskDueLabel => 'Échéance';

  @override
  String get select => 'Sélectionner';

  @override
  String get taskNotesLabel => 'Notes';

  @override
  String get save => 'Sauvegarder';

  @override
  String get logsQuickActions => 'Actions rapides';

  @override
  String get logsLike => 'J\'aime';

  @override
  String get logsLikeNote => 'Appuyez pour aimer les conseils utiles';

  @override
  String get stepsTitle => 'Pas';

  @override
  String get stepsNote => 'aujourd\'hui';

  @override
  String get sleepTitle => 'Sommeil';

  @override
  String get sleepNote => 'moy';

  @override
  String get bpTitle => 'Pression artérielle';

  @override
  String get bpNote => 'moy';

  @override
  String get hrTitle => 'Fréquence cardiaque';

  @override
  String get hrNote => 'repos';

  @override
  String get inviteSheetTitle => 'Famille / Cercle de soins';

  @override
  String get nameLabel => 'Nom';

  @override
  String get relationLabel => 'Relation';

  @override
  String get sendInvite => 'Envoyer invitation';

  @override
  String sharedWithName(String name) {
    return 'Partagé avec $name';
  }

  @override
  String get share => 'Partager';

  @override
  String get readingPrivacyTitle => 'Lecture et confidentialité';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get privacyTitle => 'Confidentialité';

  @override
  String get privacyDesc => 'Nous respectons votre vie privée.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutDesc => 'Informations de base sur l\'application.';

  @override
  String get displayTitle => 'Affichage';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeElder => 'Texte large';

  @override
  String get fontAutoNote =>
      'La police est définie automatiquement par langue.';

  @override
  String get taskAdded => 'Tâche ajoutée';

  @override
  String get exportPrepared => 'Préparation de l\'export…';

  @override
  String get sharePrepared => 'Préparation du partage…';

  @override
  String get welcomeMessage =>
      'Salut ! Je suis votre assistant santé. Posez n\'importe quelle question pour commencer.';

  @override
  String get sampleAdvice =>
      'Voici 3 conseils pour aujourd\'hui :\n1) Marchez 10 minutes à un rythme 4-2-4.\n2) Buvez un verre d\'eau.\n3) Étirez doucement votre dos et votre cou.';
}
