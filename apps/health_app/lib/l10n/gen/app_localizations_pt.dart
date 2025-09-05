// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Assistente de Saúde';

  @override
  String get navAssistant => 'Assistente';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navLogs => 'Registos';

  @override
  String get navCircle => 'Círculo';

  @override
  String get navSettings => 'Definições';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageChineseSimplified => 'Chinês (Simplificado)';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get plansTitle => 'Planos';

  @override
  String get planFreeTitle => 'Gratuito';

  @override
  String get planFreeSubtitle => 'Até 3 perguntas por dia';

  @override
  String get planStandardTitle => 'Padrão';

  @override
  String get planStandardSubtitle => 'Uso ilimitado e insights avançados';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProSubtitle => 'Ilimitado + Tempo real + Premium';

  @override
  String get modelBasic => 'Básico';

  @override
  String get modelEnhanced => 'Melhorado';

  @override
  String get modelRealtime => 'Tempo real';

  @override
  String get quotaUnlimited => 'Ilimitado';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Restantes $remaining/$total';
  }

  @override
  String get chatInputHint => 'Pergunte ao seu assistente de saúde…';

  @override
  String get send => 'Enviar';

  @override
  String get voiceHoldToTalk => 'Mantenha pressionado para falar';

  @override
  String get voiceReleaseToSend => 'Solte para enviar';

  @override
  String get actionSetTask => 'Definir como tarefa';

  @override
  String get actionExportPdf => 'Exportar PDF';

  @override
  String get actionShare => 'Partilhar';

  @override
  String get paywallTitle => 'Atingiu o limite de hoje';

  @override
  String get paywallBody =>
      'O plano gratuito inclui 3 perguntas por dia. Atualize para acesso ilimitado.';

  @override
  String get paywallLater => 'Talvez mais tarde';

  @override
  String get paywallUpgrade => 'Atualizar';

  @override
  String get paywallFootnote => '* O uso reinicia todos os dias';

  @override
  String get tasksEmpty =>
      'Ainda sem tarefas. Converta uma sugestão numa tarefa!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Prazo: $dateString';
  }

  @override
  String get taskEditTitle => 'Nova Tarefa';

  @override
  String get taskTitleLabel => 'Título';

  @override
  String get taskTitleRequired => 'Obrigatório';

  @override
  String get taskDueLabel => 'Prazo';

  @override
  String get select => 'Selecionar';

  @override
  String get taskNotesLabel => 'Notas';

  @override
  String get save => 'Guardar';

  @override
  String get logsQuickActions => 'Ações rápidas';

  @override
  String get logsLike => 'Gosto';

  @override
  String get logsLikeNote => 'Toque para gostar de dicas úteis';

  @override
  String get stepsTitle => 'Passos';

  @override
  String get stepsNote => 'hoje';

  @override
  String get sleepTitle => 'Sono';

  @override
  String get sleepNote => 'médio';

  @override
  String get bpTitle => 'Pressão Arterial';

  @override
  String get bpNote => 'médio';

  @override
  String get hrTitle => 'Frequência Cardíaca';

  @override
  String get hrNote => 'repouso';

  @override
  String get inviteSheetTitle => 'Família / Círculo de cuidados';

  @override
  String get nameLabel => 'Nome';

  @override
  String get relationLabel => 'Relação';

  @override
  String get sendInvite => 'Enviar convite';

  @override
  String sharedWithName(String name) {
    return 'Partilhado com $name';
  }

  @override
  String get share => 'Partilhar';

  @override
  String get readingPrivacyTitle => 'Leitura e privacidade';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get privacyTitle => 'Privacidade';

  @override
  String get privacyDesc => 'Respeitamos a sua privacidade.';

  @override
  String get aboutTitle => 'Acerca';

  @override
  String get aboutDesc => 'Informação básica sobre a aplicação.';

  @override
  String get displayTitle => 'Exibição';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeElder => 'Texto grande';

  @override
  String get fontAutoNote => 'A fonte é definida automaticamente por idioma.';

  @override
  String get taskAdded => 'Tarefa adicionada';

  @override
  String get exportPrepared => 'A preparar exportação…';

  @override
  String get sharePrepared => 'A preparar partilha…';

  @override
  String get welcomeMessage =>
      'Olá! Sou o seu assistente de saúde. Faça qualquer pergunta para começar.';

  @override
  String get sampleAdvice =>
      'Aqui estão 3 dicas para hoje:\n1) Caminhe 10 minutos no ritmo 4-2-4.\n2) Beba um copo de água.\n3) Alongue suavemente as costas e pescoço.';
}
