import 'api_service.dart';

class ConsentService {
  final ApiService _api = ApiService();
  static const String _basePath = '/Consents';

  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  /// Submit user consents to the backend
  Future<ApiResult<Map<String, dynamic>>> submitConsents({
    required List<ConsentItem> consents,
    required String locale,
  }) async {
    try {
      if (!_api.isAuthenticated) {
        return ApiResult.error('Not authenticated');
      }

      final payload = {
        'Consents': consents.map((c) => c.toJson()).toList(),
        'Locale': locale,
        'UserAgent': 'HealthApp/1.0',
      };
      
      print('[ConsentService] Submitting consents to $_basePath/submit');
      print('[ConsentService] Payload: ${payload.toString()}');
      
      final response = await _api.post('$_basePath/submit', payload);
      
      print('[ConsentService] Response status: ${response.statusCode}');
      print('[ConsentService] Response body: ${response.body}');

      return _api.handleResponse<Map<String, dynamic>>(response, (json) => json);
    } catch (e) {
      print('[ConsentService] Exception: $e');
      return ApiResult.error(e.toString());
    }
  }

  /// Get user's consent status
  Future<ApiResult<ConsentStatus>> getConsentStatus() async {
    try {
      if (!_api.isAuthenticated) {
        return ApiResult.error('Not authenticated');
      }

      final response = await _api.get('$_basePath/status');
      return _api.handleResponse<ConsentStatus>(
        response,
        (json) => ConsentStatus.fromJson(json),
      );
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// Get legal documents for a specific locale
  Future<ApiResult<Map<String, LegalDocument>>> getLegalDocuments(String locale) async {
    try {
      final response = await _api.get('$_basePath/documents/$locale');
      return _api.handleResponse<Map<String, LegalDocument>>(
        response,
        (json) => json.map((key, value) => MapEntry(key, LegalDocument.fromJson(value))),
      );
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// Get a specific legal document
  Future<ApiResult<LegalDocument>> getLegalDocument(String locale, String docKey) async {
    try {
      final response = await _api.get('$_basePath/documents/$locale/$docKey');
      return _api.handleResponse<LegalDocument>(
        response,
        (json) => LegalDocument.fromJson(json),
      );
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// Revoke a specific consent
  Future<ApiResult<Map<String, dynamic>>> revokeConsent(String consentId) async {
    try {
      if (!_api.isAuthenticated) {
        return ApiResult.error('Not authenticated');
      }
      final response = await _api.post('$_basePath/$consentId/revoke', {});
      return _api.handleResponse<Map<String, dynamic>>(response, (json) => json);
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }
}

/// Model for consent item
class ConsentItem {
  final ConsentType type;
  final String docKey;
  final String docVersion;
  final String contentSha256;
  final bool accepted;
  final String? recipient;
  final String? recipientCountry;

  ConsentItem({
    required this.type,
    required this.docKey,
    required this.docVersion,
    required this.contentSha256,
    required this.accepted,
    this.recipient,
    this.recipientCountry,
  });

  Map<String, dynamic> toJson() => {
    // Send enum as numeric index to match ASP.NET default enum deserialization
    'Type': type.index,
    'DocKey': docKey,
    'DocVersion': docVersion,
    'ContentSha256': contentSha256,
    'Accepted': accepted,
    if (recipient != null) 'Recipient': recipient,
    if (recipientCountry != null) 'RecipientCountry': recipientCountry,
  };
  
  static String _convertEnumName(ConsentType type) {
    // Map Dart enum to C# enum names
    switch (type) {
      case ConsentType.privacyNoticeAck:
        return 'PrivacyNoticeAck';
      case ConsentType.sensitiveProcessing:
        return 'SensitiveProcessing';
      case ConsentType.crossBorderTransfer:
        return 'CrossBorderTransfer';
      case ConsentType.thirdPartyShare:
        return 'ThirdPartyShare';
      case ConsentType.externalTransmissionAnalytics:
        return 'ExternalTransmissionAnalytics';
      case ConsentType.externalTransmissionCrash:
        return 'ExternalTransmissionCrash';
      case ConsentType.marketing:
        return 'Marketing';
      case ConsentType.termsAccept:
        return 'TermsAccept';
      case ConsentType.tokushoConfirm:
        return 'TokushoConfirm';
    }
  }
}

/// Consent types matching backend enum
enum ConsentType {
  privacyNoticeAck,
  sensitiveProcessing,
  crossBorderTransfer,
  thirdPartyShare,
  externalTransmissionAnalytics,
  externalTransmissionCrash,
  marketing,
  termsAccept,
  tokushoConfirm,
}

/// Model for consent status
class ConsentStatus {
  final bool hasAgreedToTerms;
  final bool hasAgreedToPrivacyPolicy;
  final bool hasAgreedToDataProcessing;
  final List<ConsentResponse> activeConsents;
  final DateTime? lastConsentDate;

  ConsentStatus({
    required this.hasAgreedToTerms,
    required this.hasAgreedToPrivacyPolicy,
    required this.hasAgreedToDataProcessing,
    required this.activeConsents,
    this.lastConsentDate,
  });

  factory ConsentStatus.fromJson(Map<String, dynamic> json) {
    return ConsentStatus(
      hasAgreedToTerms: json['hasAgreedToTerms'] ?? false,
      hasAgreedToPrivacyPolicy: json['hasAgreedToPrivacyPolicy'] ?? false,
      hasAgreedToDataProcessing: json['hasAgreedToDataProcessing'] ?? false,
      activeConsents: (json['activeConsents'] as List?)
          ?.map((c) => ConsentResponse.fromJson(c))
          .toList() ?? [],
      lastConsentDate: json['lastConsentDate'] != null
          ? DateTime.parse(json['lastConsentDate'])
          : null,
    );
  }
}

/// Model for consent response
class ConsentResponse {
  final String id;
  final String type;
  final String docKey;
  final String docVersion;
  final bool accepted;
  final DateTime createdAt;
  final DateTime? revokedAt;

  ConsentResponse({
    required this.id,
    required this.type,
    required this.docKey,
    required this.docVersion,
    required this.accepted,
    required this.createdAt,
    this.revokedAt,
  });

  factory ConsentResponse.fromJson(Map<String, dynamic> json) {
    return ConsentResponse(
      id: json['id'],
      type: json['type'],
      docKey: json['docKey'],
      docVersion: json['docVersion'],
      accepted: json['accepted'],
      createdAt: DateTime.parse(json['createdAt']),
      revokedAt: json['revokedAt'] != null
          ? DateTime.parse(json['revokedAt'])
          : null,
    );
  }
}

/// Model for legal document
class LegalDocument {
  final String key;
  final String version;
  final String title;
  final String content;
  final String contentSha256;
  final String locale;
  final DateTime effectiveDate;

  LegalDocument({
    required this.key,
    required this.version,
    required this.title,
    required this.content,
    required this.contentSha256,
    required this.locale,
    required this.effectiveDate,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      key: json['key'],
      version: json['version'],
      title: json['title'],
      content: json['content'],
      contentSha256: json['contentSha256'],
      locale: json['locale'],
      effectiveDate: DateTime.parse(json['effectiveDate']),
    );
  }
}
