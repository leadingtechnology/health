import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 改这个颜色即可全局换肤
  static const _seed = Color(0xFF6750A4);

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
    );

    ThemeData polish(ThemeData base) => base.copyWith(
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            surfaceTintColor: Colors.transparent, // 避免 M3 叠加高光过强
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: base.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: base.colorScheme.surface.withValues(alpha: base.brightness == Brightness.dark ? 0.12 : 0.06),
            hintStyle: TextStyle(color: base.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: base.colorScheme.secondaryContainer,
            backgroundColor: base.colorScheme.surface,
          ),
        );

    return MaterialApp(
      title: 'Polished Flutter UI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: polish(light),
      darkTheme: polish(dark),
      home: const HomeShell(),
    );
  }
}

class AppGaps {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [DiscoverPage(), SearchPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 160,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('发现'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary.withValues(alpha: 0.35), cs.secondary.withValues(alpha: 0.2)],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppGaps.md),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('新建'),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppGaps.md),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppGaps.md,
              crossAxisSpacing: AppGaps.md,
              childAspectRatio: .78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CardItem(index: index),
              childCount: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardItem extends StatelessWidget {
  const _CardItem({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://picsum.photos/seed/$index/800/1200';

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailPage(index: index, imageUrl: imageUrl)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'img$index',
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            // 渐变叠层让文案更清晰
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                  ),
                ),
              ),
            ),
            // 文案与标签
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '卡片标题 $index',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Wrap(
                    spacing: 6,
                    children: [
                      _TonedChip(label: '热门'),
                      _TonedChip(label: '推荐'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TonedChip extends StatelessWidget {
  const _TonedChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: cs.onSecondaryContainer, fontSize: 12)),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.index, required this.imageUrl});
  final int index;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('详情 $index'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'img$index', child: Image.network(imageUrl, fit: BoxFit.cover)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppGaps.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('漂亮的标题', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppGaps.sm),
                  Text(
                    '这是一段用于展示排版与可读性的示例文本。通过适当的行高、字重与对比度，可以显著提升观感与可读性。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppGaps.lg),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('主操作'),
                  ),
                  const SizedBox(height: AppGaps.md),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('次级操作'),
                  ),
                  const SizedBox(height: AppGaps.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppGaps.lg),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: cs.primary),
                          const SizedBox(width: AppGaps.md),
                          const Expanded(child: Text('在卡片与分组区块上使用合理的留白与圆角，能让信息层次更清晰。')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppGaps.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppGaps.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('搜索', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppGaps.md),
          const TextField(
            decoration: InputDecoration(
              hintText: '搜索内容…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppGaps.lg),
          const Text('最近搜索'),
          const SizedBox(height: AppGaps.sm),
          const Wrap(
            spacing: AppGaps.sm,
            children: [
              _TonedChip(label: 'UI'),
              _TonedChip(label: 'Flutter'),
              _TonedChip(label: 'Material 3'),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppGaps.lg),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: const Text('用户名'),
          subtitle: const Text('你可以在这里补充个人信息'),
          trailing: FilledButton.tonal(onPressed: () {}, child: const Text('编辑')),
        ),
        const SizedBox(height: AppGaps.lg),
        const _Section(title: '设置', children: [
          _SettingItem(icon: Icons.notifications_outlined, title: '通知'),
          _SettingItem(icon: Icons.lock_outline, title: '隐私'),
          _SettingItem(icon: Icons.color_lens_outlined, title: '主题'),
        ]),
        const _Section(title: '关于', children: [
          _SettingItem(icon: Icons.help_outline, title: '帮助与反馈'),
          _SettingItem(icon: Icons.info_outline, title: '版本信息'),
        ]),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.primary)),
        const SizedBox(height: AppGaps.md),
        Card(
          child: Column(
            children: children
                .map((c) => Column(
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(horizontal: AppGaps.md), child: c),
                        if (c != children.last) const Divider(height: 1),
                      ],
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: AppGaps.lg),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
