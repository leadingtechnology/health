import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/consent_service.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
      final res = await ConsentService().getLegalDocument(locale, 'privacy_policy');
      
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
        title: Text(_document?.title ?? (locale == 'ja' ? 'プライバシーポリシー' : 'Privacy Policy')),
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
            title: locale == 'ja' ? '1. 事業者情報' : '1. Company Information',
            content: locale == 'ja' 
              ? '''会社名：株式会社先行技術
ドメイン：ldtech.co.jp
連絡先：support@ldtech.co.jp
住所：〒341-0009 埼玉県三郷市新三郷ララシティ２丁目１－２－５０２'''
              : '''Company: LDETCH Co., Ltd.
Domain: ldetch.co.jp
Contact: support@ldetch.co.jp
Address: 2-1-2-502 Shin-Misato Lala City, Misato City, Saitama 341-0009, Japan''',
          ),
          
          _buildSection(
            context,
            title: locale == 'ja' ? '2. 個人情報の取得' : '2. Collection of Personal Information',
            content: locale == 'ja'
              ? '''当社は、以下の個人情報を取得します：
• 氏名、メールアドレス、電話番号
• 健康に関する情報（身長、体重、血圧、心拍数など）
• 医療記録、処方箋情報
• 位置情報（医療機関検索のため、ユーザーの同意がある場合のみ）
• アプリ使用履歴、ログデータ'''
              : '''We collect the following personal information:
• Name, email address, phone number
• Health-related information (height, weight, blood pressure, heart rate, etc.)
• Medical records, prescription information
• Location data (only with user consent, for medical facility search)
• App usage history, log data''',
          ),
          
          const SizedBox(height: 24),
          Text(
            locale == 'ja' 
              ? '最終更新日：2025年1月6日' 
              : 'Last Updated: January 6, 2025',
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
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
