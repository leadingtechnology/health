// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Asistente de Salud';

  @override
  String get navAssistant => 'Asistente';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navLogs => 'Registros';

  @override
  String get navCircle => 'Círculo';

  @override
  String get navSettings => 'Configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageChineseSimplified => 'Chino (Simplificado)';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get plansTitle => 'Planes';

  @override
  String get planFreeTitle => 'Gratuito';

  @override
  String get planFreeSubtitle => 'Hasta 3 preguntas por día';

  @override
  String get planStandardTitle => 'Estándar';

  @override
  String get planStandardSubtitle => 'Uso ilimitado e información avanzada';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProSubtitle => 'Ilimitado + Tiempo real + Premium';

  @override
  String get modelBasic => 'Básico';

  @override
  String get modelEnhanced => 'Mejorado';

  @override
  String get modelRealtime => 'Tiempo real';

  @override
  String get quotaUnlimited => 'Ilimitado';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Restantes $remaining/$total';
  }

  @override
  String get chatInputHint => 'Pregúntale a tu asistente de salud…';

  @override
  String get send => 'Enviar';

  @override
  String get voiceHoldToTalk => 'Mantén presionado para hablar';

  @override
  String get voiceReleaseToSend => 'Suelta para enviar';

  @override
  String get actionSetTask => 'Establecer como tarea';

  @override
  String get actionExportPdf => 'Exportar PDF';

  @override
  String get actionShare => 'Compartir';

  @override
  String get paywallTitle => 'Has alcanzado el límite de hoy';

  @override
  String get paywallBody =>
      'El plan gratuito incluye 3 preguntas por día. Actualiza para acceso ilimitado.';

  @override
  String get paywallLater => 'Quizás más tarde';

  @override
  String get paywallUpgrade => 'Actualizar';

  @override
  String get paywallFootnote => '* El uso se reinicia cada día';

  @override
  String get tasksEmpty =>
      'Aún no hay tareas. ¡Convierte una sugerencia en tarea!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Vence: $dateString';
  }

  @override
  String get taskEditTitle => 'Nueva Tarea';

  @override
  String get taskTitleLabel => 'Título';

  @override
  String get taskTitleRequired => 'Requerido';

  @override
  String get taskDueLabel => 'Vence';

  @override
  String get select => 'Seleccionar';

  @override
  String get taskNotesLabel => 'Notas';

  @override
  String get save => 'Guardar';

  @override
  String get logsQuickActions => 'Acciones rápidas';

  @override
  String get logsLike => 'Me gusta';

  @override
  String get logsLikeNote => 'Toca para dar me gusta a consejos útiles';

  @override
  String get stepsTitle => 'Pasos';

  @override
  String get stepsNote => 'hoy';

  @override
  String get sleepTitle => 'Sueño';

  @override
  String get sleepNote => 'promedio';

  @override
  String get bpTitle => 'Presión Arterial';

  @override
  String get bpNote => 'promedio';

  @override
  String get hrTitle => 'Frecuencia Cardíaca';

  @override
  String get hrNote => 'reposo';

  @override
  String get inviteSheetTitle => 'Familia / Círculo de cuidado';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get relationLabel => 'Relación';

  @override
  String get sendInvite => 'Enviar invitación';

  @override
  String sharedWithName(String name) {
    return 'Compartido con $name';
  }

  @override
  String get share => 'Compartir';

  @override
  String get readingPrivacyTitle => 'Lectura y privacidad';

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get privacyDesc => 'Respetamos tu privacidad.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutDesc => 'Información básica sobre la aplicación.';

  @override
  String get displayTitle => 'Pantalla';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeElder => 'Texto grande';

  @override
  String get fontAutoNote =>
      'La fuente se establece automáticamente por idioma.';

  @override
  String get taskAdded => 'Tarea añadida';

  @override
  String get exportPrepared => 'Preparando exportación…';

  @override
  String get sharePrepared => 'Preparando para compartir…';

  @override
  String get welcomeMessage =>
      '¡Hola! Soy tu asistente de salud. Haz cualquier pregunta para comenzar.';

  @override
  String get sampleAdvice =>
      'Aquí tienes 3 consejos para hoy:\n1) Camina 10 minutos en ritmo 4-2-4.\n2) Bebe un vaso de agua.\n3) Estira suavemente tu espalda y cuello.';
}
