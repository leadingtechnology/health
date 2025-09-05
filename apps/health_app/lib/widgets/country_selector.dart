import 'package:flutter/material.dart';

class Country {
  final String code;
  final String name;
  final String nameJa;
  final String nameZh;
  final String flag;
  
  const Country({
    required this.code,
    required this.name,
    required this.nameJa,
    required this.nameZh,
    required this.flag,
  });
}

class CountryRegionSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  
  const CountryRegionSelector({
    super.key,
    this.value,
    required this.onChanged,
    this.labelText,
  });
  
  static const List<Country> countries = [
    Country(code: 'US', name: 'United States', nameJa: 'アメリカ合衆国', nameZh: '美国', flag: '🇺🇸'),
    Country(code: 'JP', name: 'Japan', nameJa: '日本', nameZh: '日本', flag: '🇯🇵'),
    Country(code: 'CN', name: 'China', nameJa: '中国', nameZh: '中国', flag: '🇨🇳'),
    Country(code: 'KR', name: 'South Korea', nameJa: '韓国', nameZh: '韩国', flag: '🇰🇷'),
    Country(code: 'GB', name: 'United Kingdom', nameJa: 'イギリス', nameZh: '英国', flag: '🇬🇧'),
    Country(code: 'FR', name: 'France', nameJa: 'フランス', nameZh: '法国', flag: '🇫🇷'),
    Country(code: 'DE', name: 'Germany', nameJa: 'ドイツ', nameZh: '德国', flag: '🇩🇪'),
    Country(code: 'IT', name: 'Italy', nameJa: 'イタリア', nameZh: '意大利', flag: '🇮🇹'),
    Country(code: 'ES', name: 'Spain', nameJa: 'スペイン', nameZh: '西班牙', flag: '🇪🇸'),
    Country(code: 'CA', name: 'Canada', nameJa: 'カナダ', nameZh: '加拿大', flag: '🇨🇦'),
    Country(code: 'AU', name: 'Australia', nameJa: 'オーストラリア', nameZh: '澳大利亚', flag: '🇦🇺'),
    Country(code: 'IN', name: 'India', nameJa: 'インド', nameZh: '印度', flag: '🇮🇳'),
    Country(code: 'BR', name: 'Brazil', nameJa: 'ブラジル', nameZh: '巴西', flag: '🇧🇷'),
    Country(code: 'MX', name: 'Mexico', nameJa: 'メキシコ', nameZh: '墨西哥', flag: '🇲🇽'),
    Country(code: 'RU', name: 'Russia', nameJa: 'ロシア', nameZh: '俄罗斯', flag: '🇷🇺'),
    Country(code: 'SG', name: 'Singapore', nameJa: 'シンガポール', nameZh: '新加坡', flag: '🇸🇬'),
    Country(code: 'TH', name: 'Thailand', nameJa: 'タイ', nameZh: '泰国', flag: '🇹🇭'),
    Country(code: 'VN', name: 'Vietnam', nameJa: 'ベトナム', nameZh: '越南', flag: '🇻🇳'),
    Country(code: 'PH', name: 'Philippines', nameJa: 'フィリピン', nameZh: '菲律宾', flag: '🇵🇭'),
    Country(code: 'ID', name: 'Indonesia', nameJa: 'インドネシア', nameZh: '印度尼西亚', flag: '🇮🇩'),
  ];
  
  String getCountryName(Country country) {
    // Always show country names in English for consistency
    return country.name;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCountry = countries.firstWhere(
      (c) => c.code == value,
      orElse: () => countries.first,
    );
    
    return InkWell(
      onTap: () => _showCountryPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (labelText != null) ...[
                    Text(
                      labelText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    getCountryName(selectedCountry),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  labelText ?? 'Select Country',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    final isSelected = country.code == value;
                    
                    return ListTile(
                      title: Text(getCountryName(country)),
                      subtitle: Text(country.code),
                      selected: isSelected,
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        onChanged(country.code);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LanguageSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  
  const LanguageSelector({
    super.key,
    this.value,
    required this.onChanged,
    this.labelText,
  });
  
  // Show each language in its native script to prevent confusion
  // Sorted by English name alphabetically
  static const Map<String, String> languages = {
    'zh': '简体中文',        // Chinese (Simplified)
    'zh_TW': '繁體中文',     // Chinese (Traditional)
    'en': 'English',         // English
    'fr': 'Français',        // French
    'de': 'Deutsch',         // German
    'ja': '日本語',          // Japanese
    'ko': '한국어',          // Korean
    'pt': 'Português',       // Portuguese
    'ru': 'Русский',         // Russian
    'es': 'Español',         // Spanish
    'vi': 'Tiếng Việt',      // Vietnamese
  };
  
  // Display all language options with native names for clarity
  static String getLanguageDisplay(String? langCode) {
    if (langCode == null) return 'English';
    return languages[langCode] ?? 'English';
  }
  
  // Get display text showing all language names
  static String getAllLanguagesDisplay(String? selected) {
    return languages[selected] ?? 'English';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLanguage = getAllLanguagesDisplay(value);
    
    return InkWell(
      onTap: () => _showLanguagePicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (labelText != null) ...[
                    Text(
                      labelText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    selectedLanguage,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  labelText ?? 'Select Language',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: languages.entries.map((entry) {
                    final isSelected = entry.key == value;
                    return ListTile(
                      title: Text(entry.value),
                      selected: isSelected,
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        onChanged(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}