import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/consent_service.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  LegalDocument? _document;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Load document after the first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocument();
    });
  }

  Future<void> _loadDocument() async {
    if (!mounted) return;
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final res = await ConsentService().getLegalDocument(locale, 'terms_of_service');
      
      if (mounted) {
        setState(() {
          _document = res.data;
          _isLoading = false;
          if (!res.success || res.data == null) {
            _error = res.error ?? (locale == 'ja' 
              ? 'ドキュメントの読み込みに失敗しました' 
              : 'Failed to load document');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_document?.title ?? (locale == 'ja' ? '利用規約' : 'Terms of Service')),
        elevation: 0,
        actions: [
          if (_document != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _document!.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locale == 'ja' ? 'コピーしました' : 'Copied to clipboard',
                    ),
                  ),
                );
              },
              tooltip: locale == 'ja' ? 'コピー' : 'Copy',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadDocument();
              },
              child: Text(
                Localizations.localeOf(context).languageCode == 'ja' 
                  ? '再試行' 
                  : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (_document == null) {
      // Fallback to hardcoded content if API fails
      return _buildFallbackContent();
    }

    // Display markdown content from API
    return Markdown(
      data: _document!.content,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
        h2: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
        h3: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        p: Theme.of(context).textTheme.bodyMedium,
        listBullet: Theme.of(context).textTheme.bodyMedium,
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          // Handle link taps if needed
        }
      },
    );
  }

  Widget _buildFallbackContent() {
    final locale = Localizations.localeOf(context).languageCode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            title: locale == 'ja' ? '第1条（適用）' : 'Article 1 (Application)',
            content: locale == 'ja'
              ? '''本規約は、株式会社先行技術（以下「当社」）が提供する健康管理アプリケーション「Health Assistant」（以下「本サービス」）の利用条件を定めるものです。ユーザーは、本規約に同意した上で、本サービスを利用するものとします。'''
              : '''These Terms govern the use of the Health Assistant application (the "Service") provided by LDETCH Co., Ltd. (the "Company"). Users must agree to these Terms before using the Service.''',
          ),
          
          _buildSection(
            context,
            title: locale == 'ja' ? '第2条（利用登録）' : 'Article 2 (Registration)',
            content: locale == 'ja'
              ? '''1. 登録希望者は、当社の定める方法によって利用登録を申請し、当社がこれを承認することによって、利用登録が完了するものとします。
2. 当社は、以下の場合には登録申請を承認しないことがあります：
• 虚偽の情報を提供した場合
• 反社会的勢力等に該当する場合
• その他、当社が不適切と判断した場合'''
              : '''1. Registration is completed when applicants apply through our prescribed method and we approve the application.
2. We may not approve registration in the following cases:
• False information is provided
• Association with anti-social forces
• Other cases deemed inappropriate by the Company''',
          ),
          
          _buildSection(
            context,
            title: locale == 'ja' ? '第3条（医療行為の否認）' : 'Article 3 (Medical Disclaimer)',
            content: locale == 'ja'
              ? '''1. 本サービスは、健康管理の支援を目的としており、医療行為ではありません。
2. 本サービスで提供される情報は、医師の診断、治療、助言の代替となるものではありません。
3. 健康に関する決定は、必ず医療専門家に相談の上で行ってください。'''
              : '''1. This Service is for health management support and is not medical practice.
2. Information provided by the Service is not a substitute for professional medical diagnosis, treatment, or advice.
3. Health-related decisions should always be made in consultation with healthcare professionals.''',
          ),
          
          const SizedBox(height: 24),
          Text(
            locale == 'ja' 
              ? '制定日：2025年1月6日' 
              : 'Effective Date: January 6, 2025',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
