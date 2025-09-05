// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Помощник по здоровью';

  @override
  String get navAssistant => 'Помощник';

  @override
  String get navTasks => 'Задачи';

  @override
  String get navLogs => 'Журналы';

  @override
  String get navCircle => 'Круг';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'По умолчанию системы';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageChineseSimplified => 'Китайский (упрощенный)';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get plansTitle => 'Планы';

  @override
  String get planFreeTitle => 'Бесплатно';

  @override
  String get planFreeSubtitle => 'До 3 вопросов в день';

  @override
  String get planStandardTitle => 'Стандарт';

  @override
  String get planStandardSubtitle =>
      'Безлимитное использование и расширенная аналитика';

  @override
  String get planProTitle => 'Про';

  @override
  String get planProSubtitle => 'Безлимитно + Реальное время + Премиум';

  @override
  String get modelBasic => 'Базовый';

  @override
  String get modelEnhanced => 'Улучшенный';

  @override
  String get modelRealtime => 'Реальное время';

  @override
  String get quotaUnlimited => 'Безлимитно';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Осталось $remaining/$total';
  }

  @override
  String get chatInputHint => 'Спросите вашего помощника по здоровью…';

  @override
  String get send => 'Отправить';

  @override
  String get voiceHoldToTalk => 'Удерживайте для разговора';

  @override
  String get voiceReleaseToSend => 'Отпустите для отправки';

  @override
  String get actionSetTask => 'Установить как задачу';

  @override
  String get actionExportPdf => 'Экспорт в PDF';

  @override
  String get actionShare => 'Поделиться';

  @override
  String get paywallTitle => 'Вы достигли лимита на сегодня';

  @override
  String get paywallBody =>
      'Бесплатный план включает 3 вопроса в день. Обновитесь для безлимитного доступа.';

  @override
  String get paywallLater => 'Может быть позже';

  @override
  String get paywallUpgrade => 'Обновить';

  @override
  String get paywallFootnote => '* Использование сбрасывается каждый день';

  @override
  String get tasksEmpty => 'Пока нет задач. Превратите предложение в задачу!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Срок: $dateString';
  }

  @override
  String get taskEditTitle => 'Новая задача';

  @override
  String get taskTitleLabel => 'Заголовок';

  @override
  String get taskTitleRequired => 'Обязательно';

  @override
  String get taskDueLabel => 'Срок';

  @override
  String get select => 'Выбрать';

  @override
  String get taskNotesLabel => 'Заметки';

  @override
  String get save => 'Сохранить';

  @override
  String get logsQuickActions => 'Быстрые действия';

  @override
  String get logsLike => 'Нравится';

  @override
  String get logsLikeNote => 'Нажмите, чтобы лайкнуть полезные советы';

  @override
  String get stepsTitle => 'Шаги';

  @override
  String get stepsNote => 'сегодня';

  @override
  String get sleepTitle => 'Сон';

  @override
  String get sleepNote => 'среднее';

  @override
  String get bpTitle => 'Артериальное давление';

  @override
  String get bpNote => 'среднее';

  @override
  String get hrTitle => 'Пульс';

  @override
  String get hrNote => 'покой';

  @override
  String get inviteSheetTitle => 'Семья / Круг заботы';

  @override
  String get nameLabel => 'Имя';

  @override
  String get relationLabel => 'Отношение';

  @override
  String get sendInvite => 'Отправить приглашение';

  @override
  String sharedWithName(String name) {
    return 'Поделились с $name';
  }

  @override
  String get share => 'Поделиться';

  @override
  String get readingPrivacyTitle => 'Чтение и приватность';

  @override
  String get textSize => 'Размер текста';

  @override
  String get privacyTitle => 'Приватность';

  @override
  String get privacyDesc => 'Мы уважаем вашу приватность.';

  @override
  String get aboutTitle => 'О программе';

  @override
  String get aboutDesc => 'Основная информация о приложении.';

  @override
  String get displayTitle => 'Отображение';

  @override
  String get modeNormal => 'Обычный';

  @override
  String get modeElder => 'Крупный текст';

  @override
  String get fontAutoNote => 'Шрифт устанавливается автоматически по языку.';

  @override
  String get taskAdded => 'Задача добавлена';

  @override
  String get exportPrepared => 'Подготовка экспорта…';

  @override
  String get sharePrepared => 'Подготовка к отправке…';

  @override
  String get welcomeMessage =>
      'Привет! Я ваш помощник по здоровью. Задайте любой вопрос для начала.';

  @override
  String get sampleAdvice =>
      'Вот 3 совета на сегодня:\n1) Пройдитесь 10 минут в ритме 4-2-4.\n2) Выпейте стакан воды.\n3) Мягко потяните спину и шею.';
}
