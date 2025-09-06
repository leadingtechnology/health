import 'package:flutter/material.dart';
import '../pages/legal/privacy_policy_page.dart';
import '../pages/legal/terms_of_service_page.dart';
import '../services/consent_service.dart';

class ConsentDialog extends StatefulWidget {
  const ConsentDialog({super.key});

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _dataProcessingAccepted = false;
  bool _crossBorderAccepted = false;
  bool _isLoading = false;
  Map<String, LegalDocument>? _documents;
  
  bool get _allAccepted => _termsAccepted && _privacyAccepted && _dataProcessingAccepted && _crossBorderAccepted;
  
  @override
  void initState() {
    super.initState();
    // Load documents after the first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLegalDocuments();
    });
  }
  
  Future<void> _loadLegalDocuments() async {
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    final docsRes = await ConsentService().getLegalDocuments(locale);
    if (mounted) {
      setState(() {
        _documents = docsRes.success ? docsRes.data : null;
      });
      if (!docsRes.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(docsRes.error ?? 'Failed to load documents')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'ja' ? '利用規約への同意' : 'Consent Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              locale == 'ja' 
                ? 'サービスをご利用いただくには、以下の規約に同意していただく必要があります。'
                : 'To use our service, you must agree to the following terms.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Terms of Service
            _buildConsentItem(
              context,
              checked: _termsAccepted,
              onChanged: (value) => setState(() => _termsAccepted = value ?? false),
              label: locale == 'ja' ? '利用規約' : 'Terms of Service',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
              ),
            ),
            
            // Privacy Policy
            _buildConsentItem(
              context,
              checked: _privacyAccepted,
              onChanged: (value) => setState(() => _privacyAccepted = value ?? false),
              label: locale == 'ja' ? 'プライバシーポリシー' : 'Privacy Policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
            ),
            
            // Data Processing Consent
            _buildConsentItem(
              context,
              checked: _dataProcessingAccepted,
              onChanged: (value) => setState(() => _dataProcessingAccepted = value ?? false),
              label: locale == 'ja' 
                ? '健康情報の取得・処理への同意' 
                : 'Consent to Health Data Processing',
              subtitle: locale == 'ja'
                ? '健康に関する情報をAIで分析し、アドバイスを提供することに同意します'
                : 'I consent to AI analysis of health data for providing advice',
            ),
            
            // Cross-border Transfer Consent
            _buildConsentItem(
              context,
              checked: _crossBorderAccepted,
              onChanged: (value) => setState(() => _crossBorderAccepted = value ?? false),
              label: locale == 'ja' 
                ? '越境データ移転への同意' 
                : 'Cross-Border Data Transfer',
              subtitle: locale == 'ja'
                ? 'AI処理のため、データが米国等へ移転されることに同意します'
                : 'I consent to data transfer to US and other countries for AI processing',
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    locale == 'ja' ? 'キャンセル' : 'Cancel',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: !_isLoading
                    ? () {
                        if (_allAccepted) {
                          _submitConsents();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                locale == 'ja'
                                  ? '続行するにはすべてに同意してください'
                                  : 'Please agree to all items to continue',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        locale == 'ja' ? '同意して続ける' : 'Agree and Continue',
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConsentItem(
    BuildContext context, {
    required bool checked,
    required ValueChanged<bool?> onChanged,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: checked,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onTap != null)
                  InkWell(
                    onTap: onTap,
                    child: Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitConsents() async {
    setState(() => _isLoading = true);
    
    final locale = Localizations.localeOf(context).languageCode;
    
    // Prepare consent items
    final consents = <ConsentItem>[];
    
    // Terms of Service
    if (_termsAccepted) {
      final doc = _documents?['terms_of_service'];
      consents.add(ConsentItem(
        type: ConsentType.termsAccept,
        docKey: 'terms_of_service',
        docVersion: doc?.version ?? '2025-01-06',
        contentSha256: doc?.contentSha256 ?? '',
        accepted: true,
      ));
    }
    
    // Privacy Policy
    if (_privacyAccepted) {
      final doc = _documents?['privacy_policy'];
      consents.add(ConsentItem(
        type: ConsentType.privacyNoticeAck,
        docKey: 'privacy_policy',
        docVersion: doc?.version ?? '2025-01-06',
        contentSha256: doc?.contentSha256 ?? '',
        accepted: true,
      ));
    }
    
    // Data Processing
    if (_dataProcessingAccepted) {
      final doc = _documents?['data_processing_consent'];
      consents.add(ConsentItem(
        type: ConsentType.sensitiveProcessing,
        docKey: 'data_processing_consent',
        docVersion: doc?.version ?? '2025-01-06',
        contentSha256: doc?.contentSha256 ?? '',
        accepted: true,
      ));
    }
    
    // Cross-border Transfer
    if (_crossBorderAccepted) {
      final doc = _documents?['cross_border_transfer'];
      consents.add(ConsentItem(
        type: ConsentType.crossBorderTransfer,
        docKey: 'cross_border_transfer',
        docVersion: doc?.version ?? '2025-01-06',
        contentSha256: doc?.contentSha256 ?? '',
        accepted: true,
        recipient: 'OpenAI',
        recipientCountry: 'US',
      ));
    }
    
    // Submit to backend
    final submitRes = await ConsentService().submitConsents(
      consents: consents,
      locale: locale,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (submitRes.success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              submitRes.error ?? (locale == 'ja' 
                ? '同意の保存に失敗しました' 
                : 'Failed to save consent'),
            ),
          ),
        );
      }
    }
  }
}

Future<bool> showConsentDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const ConsentDialog(),
  );
  return result ?? false;
}
