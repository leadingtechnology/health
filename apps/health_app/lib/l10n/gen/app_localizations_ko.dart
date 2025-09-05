// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '건강 어시스턴트';

  @override
  String get navAssistant => '어시스턴트';

  @override
  String get navTasks => '작업';

  @override
  String get navLogs => '기록';

  @override
  String get navCircle => '서클';

  @override
  String get navSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSystem => '시스템 기본값';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageChineseSimplified => '중국어 (간체)';

  @override
  String get languageJapanese => '일본어';

  @override
  String get plansTitle => '요금제';

  @override
  String get planFreeTitle => '무료';

  @override
  String get planFreeSubtitle => '하루 최대 3회 질문';

  @override
  String get planStandardTitle => '스탠다드';

  @override
  String get planStandardSubtitle => '무제한 사용 및 고급 인사이트';

  @override
  String get planProTitle => '프로';

  @override
  String get planProSubtitle => '무제한 + 실시간 + 프리미엄';

  @override
  String get modelBasic => '기본';

  @override
  String get modelEnhanced => '향상됨';

  @override
  String get modelRealtime => '실시간';

  @override
  String get quotaUnlimited => '무제한';

  @override
  String quotaRemaining(int remaining, int total) {
    return '남은 횟수 $remaining/$total';
  }

  @override
  String get chatInputHint => '건강 어시스턴트에게 물어보세요…';

  @override
  String get send => '전송';

  @override
  String get voiceHoldToTalk => '누르고 말하기';

  @override
  String get voiceReleaseToSend => '놓으면 전송';

  @override
  String get actionSetTask => '작업으로 설정';

  @override
  String get actionExportPdf => 'PDF 내보내기';

  @override
  String get actionShare => '공유';

  @override
  String get paywallTitle => '오늘의 한도에 도달했습니다';

  @override
  String get paywallBody => '무료 요금제는 하루 3회 질문이 포함됩니다. 무제한 액세스를 위해 업그레이드하세요.';

  @override
  String get paywallLater => '나중에';

  @override
  String get paywallUpgrade => '업그레이드';

  @override
  String get paywallFootnote => '* 사용량은 매일 초기화됩니다';

  @override
  String get tasksEmpty => '아직 작업이 없습니다. 제안을 작업으로 변환해보세요!';

  @override
  String dueLabel(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('yMMMd jm', localeName);
    final String dateString = dateDateFormat.format(date);

    return '마감: $dateString';
  }

  @override
  String get taskEditTitle => '새 작업';

  @override
  String get taskTitleLabel => '제목';

  @override
  String get taskTitleRequired => '필수';

  @override
  String get taskDueLabel => '마감';

  @override
  String get select => '선택';

  @override
  String get taskNotesLabel => '메모';

  @override
  String get save => '저장';

  @override
  String get logsQuickActions => '빠른 작업';

  @override
  String get logsLike => '좋아요';

  @override
  String get logsLikeNote => '유용한 팁에 좋아요를 누르세요';

  @override
  String get stepsTitle => '걸음 수';

  @override
  String get stepsNote => '오늘';

  @override
  String get sleepTitle => '수면';

  @override
  String get sleepNote => '평균';

  @override
  String get bpTitle => '혈압';

  @override
  String get bpNote => '평균';

  @override
  String get hrTitle => '심박수';

  @override
  String get hrNote => '안정시';

  @override
  String get inviteSheetTitle => '가족 / 돌봄 서클';

  @override
  String get nameLabel => '이름';

  @override
  String get relationLabel => '관계';

  @override
  String get sendInvite => '초대 보내기';

  @override
  String sharedWithName(String name) {
    return '$name와 공유됨';
  }

  @override
  String get share => '공유';

  @override
  String get readingPrivacyTitle => '읽기 및 개인정보보호';

  @override
  String get textSize => '텍스트 크기';

  @override
  String get privacyTitle => '개인정보보호';

  @override
  String get privacyDesc => '귀하의 개인정보를 존중합니다.';

  @override
  String get aboutTitle => '정보';

  @override
  String get aboutDesc => '앱에 대한 기본 정보입니다.';

  @override
  String get displayTitle => '화면';

  @override
  String get modeNormal => '일반';

  @override
  String get modeElder => '큰 텍스트';

  @override
  String get fontAutoNote => '글꼴은 언어에 따라 자동으로 설정됩니다.';

  @override
  String get taskAdded => '작업 추가됨';

  @override
  String get exportPrepared => '내보내기 준비 중…';

  @override
  String get sharePrepared => '공유 준비 중…';

  @override
  String get welcomeMessage => '안녕하세요! 저는 귀하의 건강 어시스턴트입니다. 궁금한 것을 물어보세요.';

  @override
  String get sampleAdvice =>
      '오늘의 3가지 팁:\n1) 4-2-4 페이스로 10분간 걸으세요.\n2) 물 한 잔을 마시세요.\n3) 등과 목을 부드럽게 스트레칭하세요.';
}
