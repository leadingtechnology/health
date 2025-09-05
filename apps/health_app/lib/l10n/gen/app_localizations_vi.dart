// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Trợ lý Sức khỏe';

  @override
  String get navAssistant => 'Trợ lý';

  @override
  String get navTasks => 'Nhiệm vụ';

  @override
  String get navLogs => 'Nhật ký';

  @override
  String get navCircle => 'Vòng tròn';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageSystem => 'Mặc định hệ thống';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get languageChineseSimplified => 'Tiếng Trung (Giản thể)';

  @override
  String get languageJapanese => 'Tiếng Nhật';

  @override
  String get plansTitle => 'Gói dịch vụ';

  @override
  String get planFreeTitle => 'Miễn phí';

  @override
  String get planFreeSubtitle => 'Tối đa 3 câu hỏi mỗi ngày';

  @override
  String get planStandardTitle => 'Tiêu chuẩn';

  @override
  String get planStandardSubtitle =>
      'Sử dụng không giới hạn và thông tin chi tiết nâng cao';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProSubtitle => 'Không giới hạn + Thời gian thực + Premium';

  @override
  String get modelBasic => 'Cơ bản';

  @override
  String get modelEnhanced => 'Nâng cao';

  @override
  String get modelRealtime => 'Thời gian thực';

  @override
  String get quotaUnlimited => 'Không giới hạn';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Còn lại $remaining/$total';
  }

  @override
  String get chatInputHint => 'Hỏi trợ lý sức khỏe của bạn…';

  @override
  String get send => 'Gửi';

  @override
  String get voiceHoldToTalk => 'Giữ để nói';

  @override
  String get voiceReleaseToSend => 'Thả để gửi';

  @override
  String get actionSetTask => 'Đặt làm nhiệm vụ';

  @override
  String get actionExportPdf => 'Xuất PDF';

  @override
  String get actionShare => 'Chia sẻ';

  @override
  String get paywallTitle => 'Bạn đã đạt đến giới hạn hôm nay';

  @override
  String get paywallBody =>
      'Gói miễn phí bao gồm 3 câu hỏi mỗi ngày. Nâng cấp để truy cập không giới hạn.';

  @override
  String get paywallLater => 'Có thể sau';

  @override
  String get paywallUpgrade => 'Nâng cấp';

  @override
  String get paywallFootnote => '* Việc sử dụng được đặt lại mỗi ngày';

  @override
  String get tasksEmpty =>
      'Chưa có nhiệm vụ nào. Chuyển đổi một gợi ý thành nhiệm vụ!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Hạn: $dateString';
  }

  @override
  String get taskEditTitle => 'Nhiệm vụ mới';

  @override
  String get taskTitleLabel => 'Tiêu đề';

  @override
  String get taskTitleRequired => 'Bắt buộc';

  @override
  String get taskDueLabel => 'Hạn';

  @override
  String get select => 'Chọn';

  @override
  String get taskNotesLabel => 'Ghi chú';

  @override
  String get save => 'Lưu';

  @override
  String get logsQuickActions => 'Hành động nhanh';

  @override
  String get logsLike => 'Thích';

  @override
  String get logsLikeNote => 'Chạm để thích những mẹo hữu ích';

  @override
  String get stepsTitle => 'Bước chân';

  @override
  String get stepsNote => 'hôm nay';

  @override
  String get sleepTitle => 'Giấc ngủ';

  @override
  String get sleepNote => 'trung bình';

  @override
  String get bpTitle => 'Huyết áp';

  @override
  String get bpNote => 'trung bình';

  @override
  String get hrTitle => 'Nhịp tim';

  @override
  String get hrNote => 'nghỉ';

  @override
  String get inviteSheetTitle => 'Gia đình / Vòng tròn chăm sóc';

  @override
  String get nameLabel => 'Tên';

  @override
  String get relationLabel => 'Mối quan hệ';

  @override
  String get sendInvite => 'Gửi lời mời';

  @override
  String sharedWithName(String name) {
    return 'Đã chia sẻ với $name';
  }

  @override
  String get share => 'Chia sẻ';

  @override
  String get readingPrivacyTitle => 'Đọc và quyền riêng tư';

  @override
  String get textSize => 'Cỡ chữ';

  @override
  String get privacyTitle => 'Quyền riêng tư';

  @override
  String get privacyDesc => 'Chúng tôi tôn trọng quyền riêng tư của bạn.';

  @override
  String get aboutTitle => 'Về ứng dụng';

  @override
  String get aboutDesc => 'Thông tin cơ bản về ứng dụng.';

  @override
  String get displayTitle => 'Hiển thị';

  @override
  String get modeNormal => 'Bình thường';

  @override
  String get modeElder => 'Chữ lớn';

  @override
  String get fontAutoNote => 'Phông chữ được đặt tự động theo ngôn ngữ.';

  @override
  String get taskAdded => 'Đã thêm nhiệm vụ';

  @override
  String get exportPrepared => 'Đang chuẩn bị xuất…';

  @override
  String get sharePrepared => 'Đang chuẩn bị chia sẻ…';

  @override
  String get welcomeMessage =>
      'Xin chào! Tôi là trợ lý sức khỏe của bạn. Hỏi bất cứ điều gì để bắt đầu.';

  @override
  String get sampleAdvice =>
      'Đây là 3 lời khuyên cho hôm nay:\n1) Đi bộ 10 phút theo nhịp 4-2-4.\n2) Uống một cốc nước.\n3) Duỗi lưng và cổ nhẹ nhàng.';
}
