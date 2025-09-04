import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    // Settings icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.settingsTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Customize your experience',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile avatar
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        state.userName?.isNotEmpty == true 
                            ? state.userName![0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                _buildSectionCard(
                  context,
                  title: t.displayTitle,
                  icon: Icons.palette,
                  children: [
                    _buildSubsection(
                      context,
                      title: 'Theme Mode',
                      child: _ThemeModeSelector(),
                    ),
                    const SizedBox(height: 16),
                    _buildSubsection(
                      context,
                      title: 'Theme Color',
                      child: _SeedColorPicker(),
                    ),
                    const SizedBox(height: 16),
                    _buildSubsection(
                      context,
                      title: 'Text Size',
                      child: _TextSizeSelector(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Language Section
                _buildSectionCard(
                  context,
                  title: t.settingsLanguage,
                  icon: Icons.language,
                  children: [
                    _LanguageSelector(),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Subscription Section
                _buildSectionCard(
                  context,
                  title: t.plansTitle,
                  icon: Icons.diamond,
                  gradient: true,
                  children: [
                    _PlanSelector(),
                    const SizedBox(height: 16),
                    _ModelTierSelector(),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Account Section
                _buildSectionCard(
                  context,
                  title: 'Account',
                  icon: Icons.person,
                  children: [
                    _buildAccountTile(
                      context,
                      title: 'Profile',
                      subtitle: state.userEmail ?? 'Not logged in',
                      icon: Icons.account_circle,
                      onTap: () {},
                    ),
                    _buildAccountTile(
                      context,
                      title: 'Security',
                      subtitle: 'Manage your security settings',
                      icon: Icons.security,
                      onTap: () {},
                    ),
                    _buildAccountTile(
                      context,
                      title: 'Notifications',
                      subtitle: 'Configure alerts and reminders',
                      icon: Icons.notifications,
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // About Section
                _buildSectionCard(
                  context,
                  title: 'About',
                  icon: Icons.info,
                  children: [
                    _buildInfoTile(
                      context,
                      title: t.privacyTitle,
                      subtitle: t.privacyDesc,
                      icon: Icons.privacy_tip,
                      onTap: () {},
                    ),
                    _buildInfoTile(
                      context,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms and conditions',
                      icon: Icons.description,
                      onTap: () {},
                    ),
                    _buildInfoTile(
                      context,
                      title: t.aboutTitle,
                      subtitle: 'Version 1.0.0',
                      icon: Icons.info_outline,
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<AppState>().logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool gradient = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: gradient
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.5),
                    theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  ],
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubsection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final selected = state.themeMode;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              context,
              mode: ThemeMode.light,
              icon: Icons.light_mode,
              label: 'Light',
              selected: selected == ThemeMode.light,
            ),
          ),
          Expanded(
            child: _buildModeButton(
              context,
              mode: ThemeMode.dark,
              icon: Icons.dark_mode,
              label: 'Dark',
              selected: selected == ThemeMode.dark,
            ),
          ),
          Expanded(
            child: _buildModeButton(
              context,
              mode: ThemeMode.system,
              icon: Icons.phone_iphone,
              label: 'System',
              selected: selected == ThemeMode.system,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.read<AppState>().setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextSizeSelector extends StatelessWidget {
  const _TextSizeSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildSizeButton(
              context,
              label: 'Normal',
              icon: Icons.text_fields,
              selected: !state.elderMode,
              onTap: () => context.read<AppState>().setElderMode(false),
            ),
          ),
          Expanded(
            child: _buildSizeButton(
              context,
              label: 'Large',
              icon: Icons.format_size,
              selected: state.elderMode,
              onTap: () => context.read<AppState>().setElderMode(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    
    String current = 'system';
    if (state.locale?.languageCode == 'en') current = 'en';
    if (state.locale?.languageCode == 'zh') current = 'zh';
    if (state.locale?.languageCode == 'ja') current = 'ja';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(value: 'system', child: Text('🌐 System default')),
            DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
            DropdownMenuItem(value: 'zh', child: Text('🇨🇳 简体中文')),
            DropdownMenuItem(value: 'ja', child: Text('🇯🇵 日本語')),
          ],
          onChanged: (v) => context.read<AppState>().setLocaleCode(v!),
        ),
      ),
    );
  }
}

class _SeedColorPicker extends StatelessWidget {
  const _SeedColorPicker();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final current = Color(state.seedColor);
    
    const List<Color> seeds = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.orange,
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in seeds)
          GestureDetector(
            onTap: () => context.read<AppState>().setSeedColor(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: current.value == c.value 
                      ? theme.colorScheme.outline
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: current.value == c.value
                    ? [
                        BoxShadow(
                          color: c.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: current.value == c.value
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _PlanSelector extends StatelessWidget {
  const _PlanSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;
    final currentPlan = state.plan;

    return Column(
      children: [
        _buildPlanOption(
          context,
          plan: Plan.free,
          title: t.planFreeTitle,
          subtitle: t.planFreeSubtitle,
          features: ['3 questions per day', 'Basic AI model'],
          selected: currentPlan == Plan.free,
        ),
        const SizedBox(height: 8),
        _buildPlanOption(
          context,
          plan: Plan.standard,
          title: t.planStandardTitle,
          subtitle: t.planStandardSubtitle,
          features: ['50 questions per day', 'Enhanced AI model', 'Priority support'],
          selected: currentPlan == Plan.standard,
          recommended: true,
        ),
        const SizedBox(height: 8),
        _buildPlanOption(
          context,
          plan: Plan.pro,
          title: t.planProTitle,
          subtitle: t.planProSubtitle,
          features: ['Unlimited questions', 'All AI models', 'Premium features'],
          selected: currentPlan == Plan.pro,
        ),
      ],
    );
  }

  Widget _buildPlanOption(
    BuildContext context, {
    required Plan plan,
    required String title,
    required String subtitle,
    required List<String> features,
    required bool selected,
    bool recommended = false,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.read<AppState>().setPlan(plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected 
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (recommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ModelTierSelector extends StatelessWidget {
  const _ModelTierSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentTier = state.modelTier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Model',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _buildTierButton(
                  context,
                  tier: ModelTier.basic,
                  label: t.modelBasic,
                  icon: Icons.speed,
                  selected: currentTier == ModelTier.basic,
                ),
              ),
              Expanded(
                child: _buildTierButton(
                  context,
                  tier: ModelTier.enhanced,
                  label: t.modelEnhanced,
                  icon: Icons.rocket_launch,
                  selected: currentTier == ModelTier.enhanced,
                ),
              ),
              Expanded(
                child: _buildTierButton(
                  context,
                  tier: ModelTier.realtime,
                  label: t.modelRealtime,
                  icon: Icons.bolt,
                  selected: currentTier == ModelTier.realtime,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTierButton(
    BuildContext context, {
    required ModelTier tier,
    required String label,
    required IconData icon,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.read<AppState>().setModelTier(tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}