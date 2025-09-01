// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ヘルスアシスタント';

  @override
  String get navAssistant => 'アシスタント';

  @override
  String get navTasks => 'タスク';

  @override
  String get navLogs => 'ログ';

  @override
  String get navCircle => 'サークル';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => 'システムに従う';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageChineseSimplified => '簡体字中国語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get plansTitle => 'プラン';

  @override
  String get planFreeTitle => 'フリー';

  @override
  String get planFreeSubtitle => '1日 最大3回の質問';

  @override
  String get planStandardTitle => 'スタンダード';

  @override
  String get planStandardSubtitle => '無制限利用と高度なインサイト';

  @override
  String get planProTitle => 'プロ';

  @override
  String get planProSubtitle => '無制限 + リアルタイム + プレミアム';

  @override
  String get modelBasic => 'ベーシック';

  @override
  String get modelEnhanced => 'エンハンスド';

  @override
  String get modelRealtime => 'リアルタイム';

  @override
  String get quotaUnlimited => '無制限';

  @override
  String quotaRemaining(int remaining, int total) {
    return '残り $remaining/$total';
  }

  @override
  String get chatInputHint => 'ヘルスアシスタントに質問…';

  @override
  String get send => '送信';

  @override
  String get voiceHoldToTalk => '長押しで話す';

  @override
  String get voiceReleaseToSend => '離して送信';

  @override
  String get actionSetTask => 'タスクに追加';

  @override
  String get actionExportPdf => 'PDFに書き出し';

  @override
  String get actionShare => '共有';

  @override
  String get paywallTitle => '本日の上限に達しました';

  @override
  String get paywallBody => 'フリープランは1日3回まで。アップグレードで無制限。';

  @override
  String get paywallLater => '後で';

  @override
  String get paywallUpgrade => 'アップグレード';

  @override
  String get paywallFootnote => '* 利用回数は毎日リセット';

  @override
  String get tasksEmpty => 'まだタスクがありません。提案をタスクにしましょう！';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return '期限: $dateString';
  }

  @override
  String get taskEditTitle => '新規タスク';

  @override
  String get taskTitleLabel => 'タイトル';

  @override
  String get taskTitleRequired => '必須';

  @override
  String get taskDueLabel => '期限';

  @override
  String get select => '選択';

  @override
  String get taskNotesLabel => 'メモ';

  @override
  String get save => '保存';

  @override
  String get logsQuickActions => 'クイックアクション';

  @override
  String get logsLike => 'いいね';

  @override
  String get logsLikeNote => '役立つ提案にいいね';

  @override
  String get stepsTitle => '歩数';

  @override
  String get stepsNote => '今日';

  @override
  String get sleepTitle => '睡眠';

  @override
  String get sleepNote => '平均';

  @override
  String get bpTitle => '血圧';

  @override
  String get bpNote => '平均';

  @override
  String get hrTitle => '心拍数';

  @override
  String get hrNote => '安静時';

  @override
  String get inviteSheetTitle => '家族 / ケアサークル';

  @override
  String get nameLabel => '氏名';

  @override
  String get relationLabel => '関係';

  @override
  String get sendInvite => '招待を送信';

  @override
  String sharedWithName(String name) {
    return '$name に共有を送信しました';
  }

  @override
  String get share => '共有';

  @override
  String get readingPrivacyTitle => '読みやすさとプライバシー';

  @override
  String get textSize => '文字サイズ';

  @override
  String get privacyTitle => 'プライバシー';

  @override
  String get privacyDesc => 'プライバシーを尊重します。';

  @override
  String get aboutTitle => '情報';

  @override
  String get aboutDesc => 'アプリに関する基本情報。';

  @override
  String get displayTitle => '表示';

  @override
  String get modeNormal => '通常';

  @override
  String get modeElder => '大きい文字';

  @override
  String get fontAutoNote => '言語に合わせてフォントを自動設定します。';

  @override
  String get taskAdded => 'タスクを追加しました';

  @override
  String get exportPrepared => 'エクスポートを準備中…';

  @override
  String get sharePrepared => '共有を準備中…';

  @override
  String get welcomeMessage => 'こんにちは！ヘルスアシスタントです。まずは質問してみてください。';

  @override
  String get sampleAdvice =>
      '本日の3つのヒント:\n1) 4-2-4のリズムで10分歩く\n2) 水を一杯飲む\n3) 背中と首をやさしくストレッチ';
}
