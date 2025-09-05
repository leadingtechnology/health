// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '健康助手';

  @override
  String get navAssistant => '助理';

  @override
  String get navTasks => '任务';

  @override
  String get navLogs => '日志';

  @override
  String get navCircle => '亲友';

  @override
  String get navSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageJapanese => '日语';

  @override
  String get plansTitle => '套餐';

  @override
  String get planFreeTitle => '免费';

  @override
  String get planFreeSubtitle => '每天最多 3 次提问';

  @override
  String get planStandardTitle => '标准';

  @override
  String get planStandardSubtitle => '不限次数，进阶洞察';

  @override
  String get planProTitle => '专业版';

  @override
  String get planProSubtitle => '不限次数 + 实时 + 高级功能';

  @override
  String get modelBasic => '基础';

  @override
  String get modelEnhanced => '增强';

  @override
  String get modelRealtime => '实时';

  @override
  String get quotaUnlimited => '无限';

  @override
  String quotaRemaining(int remaining, int total) {
    return '剩余 $remaining/$total';
  }

  @override
  String get chatInputHint => '向健康助手提问…';

  @override
  String get send => '发送';

  @override
  String get voiceHoldToTalk => '按住说话';

  @override
  String get voiceReleaseToSend => '松开发送';

  @override
  String get actionSetTask => '设为任务';

  @override
  String get actionExportPdf => '导出 PDF';

  @override
  String get actionShare => '分享';

  @override
  String get paywallTitle => '已达到今日次数上限';

  @override
  String get paywallBody => '免费版每天包含 3 次提问。升级后无限制。';

  @override
  String get paywallLater => '稍后再说';

  @override
  String get paywallUpgrade => '升级';

  @override
  String get paywallFootnote => '* 使用次数每日重置';

  @override
  String get tasksEmpty => '还没有任务。可将建议转为任务！';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return '截止：$dateString';
  }

  @override
  String get taskEditTitle => '新任务';

  @override
  String get taskTitleLabel => '标题';

  @override
  String get taskTitleRequired => '必填';

  @override
  String get taskDueLabel => '截止';

  @override
  String get select => '选择';

  @override
  String get taskNotesLabel => '备注';

  @override
  String get save => '保存';

  @override
  String get logsQuickActions => '快捷操作';

  @override
  String get logsLike => '点赞';

  @override
  String get logsLikeNote => '点按点赞有用的建议';

  @override
  String get stepsTitle => '步数';

  @override
  String get stepsNote => '今日';

  @override
  String get sleepTitle => '睡眠';

  @override
  String get sleepNote => '平均';

  @override
  String get bpTitle => '血压';

  @override
  String get bpNote => '平均';

  @override
  String get hrTitle => '心率';

  @override
  String get hrNote => '静息';

  @override
  String get inviteSheetTitle => '家人 / 亲友';

  @override
  String get nameLabel => '姓名';

  @override
  String get relationLabel => '关系';

  @override
  String get sendInvite => '发送邀请';

  @override
  String sharedWithName(String name) {
    return '已向 $name 发送分享';
  }

  @override
  String get share => '分享';

  @override
  String get readingPrivacyTitle => '阅读与隐私';

  @override
  String get textSize => '文字大小';

  @override
  String get privacyTitle => '隐私';

  @override
  String get privacyDesc => '我们重视您的隐私。';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutDesc => '关于应用的基本信息。';

  @override
  String get displayTitle => '显示';

  @override
  String get modeNormal => '普通模式';

  @override
  String get modeElder => '大字号';

  @override
  String get fontAutoNote => '字体将根据语言自动设置。';

  @override
  String get taskAdded => '已添加任务';

  @override
  String get exportPrepared => '正在准备导出…';

  @override
  String get sharePrepared => '正在准备分享…';

  @override
  String get welcomeMessage => '你好！我是你的健康助手。开始向我提问吧。';

  @override
  String get sampleAdvice =>
      '今天的 3 个建议：\n1）以 4-2-4 节奏步行 10 分钟；\n2）喝一杯水；\n3）轻柔拉伸背部和颈部。';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '健康助手';

  @override
  String get navAssistant => '助手';

  @override
  String get navTasks => '任務';

  @override
  String get navLogs => '記錄';

  @override
  String get navCircle => '圈子';

  @override
  String get navSettings => '設置';

  @override
  String get settingsTitle => '設置';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageSystem => '系統默認';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageChineseSimplified => '簡體中文';

  @override
  String get languageJapanese => '日語';

  @override
  String get plansTitle => '方案';

  @override
  String get planFreeTitle => '免費';

  @override
  String get planFreeSubtitle => '每天最多3次諮詢';

  @override
  String get planStandardTitle => '標準';

  @override
  String get planStandardSubtitle => '無限使用和高級洞察';

  @override
  String get planProTitle => '專業';

  @override
  String get planProSubtitle => '無限 + 實時 + 高級';

  @override
  String get modelBasic => '基本';

  @override
  String get modelEnhanced => '增強';

  @override
  String get modelRealtime => '實時';

  @override
  String get quotaUnlimited => '無限';

  @override
  String quotaRemaining(int remaining, int total) {
    return '剩餘 $remaining/$total';
  }

  @override
  String get chatInputHint => '詢問您的健康助手...';

  @override
  String get send => '發送';

  @override
  String get voiceHoldToTalk => '按住說話';

  @override
  String get voiceReleaseToSend => '鬆開發送';

  @override
  String get actionSetTask => '設為任務';

  @override
  String get actionExportPdf => '導出PDF';

  @override
  String get actionShare => '分享';

  @override
  String get paywallTitle => '您已達到今天的限制';

  @override
  String get paywallBody => '免費方案每天包含3次諮詢。升級以無限制訪問。';

  @override
  String get paywallLater => '稍後再說';

  @override
  String get paywallUpgrade => '升級';

  @override
  String get paywallFootnote => '* 使用量每天重置';

  @override
  String get tasksEmpty => '還沒有任務。將建議轉換為任務！';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return '到期：$dateString';
  }

  @override
  String get taskEditTitle => '新任務';

  @override
  String get taskTitleLabel => '標題';

  @override
  String get taskTitleRequired => '必填';

  @override
  String get taskDueLabel => '到期';

  @override
  String get select => '選擇';

  @override
  String get taskNotesLabel => '備註';

  @override
  String get save => '保存';

  @override
  String get logsQuickActions => '快速操作';

  @override
  String get logsLike => '喜歡';

  @override
  String get logsLikeNote => '點擊以喜歡有用的提示';

  @override
  String get stepsTitle => '步數';

  @override
  String get stepsNote => '今天';

  @override
  String get sleepTitle => '睡眠';

  @override
  String get sleepNote => '平均';

  @override
  String get bpTitle => '血壓';

  @override
  String get bpNote => '平均';

  @override
  String get hrTitle => '心率';

  @override
  String get hrNote => '靜息';

  @override
  String get inviteSheetTitle => '家庭/護理圈';

  @override
  String get nameLabel => '姓名';

  @override
  String get relationLabel => '關係';

  @override
  String get sendInvite => '發送邀請';

  @override
  String sharedWithName(String name) {
    return '已分享給 $name';
  }

  @override
  String get share => '分享';

  @override
  String get readingPrivacyTitle => '閱讀和隱私';

  @override
  String get textSize => '文字大小';

  @override
  String get privacyTitle => '隱私';

  @override
  String get privacyDesc => '我們尊重您的隱私。';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutDesc => '應用程序的基本信息。';

  @override
  String get displayTitle => '顯示';

  @override
  String get modeNormal => '正常';

  @override
  String get modeElder => '大文字';

  @override
  String get fontAutoNote => '字體由語言自動設置。';

  @override
  String get taskAdded => '任務已添加';

  @override
  String get exportPrepared => '準備導出...';

  @override
  String get sharePrepared => '準備分享...';

  @override
  String get welcomeMessage => '嗨！我是您的健康助手。詢問任何問題以開始。';

  @override
  String get sampleAdvice =>
      '今天的3個建議：\n1) 以4-2-4節奏步行10分鐘。\n2) 喝一杯水。\n3) 輕輕伸展背部和頸部。';
}
