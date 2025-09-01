import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.md, AppGaps.md, AppGaps.md),
        itemCount: state.members.length,
        itemBuilder: (ctx, i) {
          final m = state.members[i];
          return ListTile(
            leading: CircleAvatar(child: Icon(m.icon)),
            title: Text(m.name),
            subtitle: Text(m.relation),
            trailing: FilledButton.tonalIcon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.sharedWithName(m.name))));
              },
              icon: const Icon(Icons.share),
              label: Text(t.share),
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add_alt_1),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (ctx) => const _InviteSheet(),
          );
        },
      ),
    );
  }
}

class _InviteSheet extends StatelessWidget {
  const _InviteSheet();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.md, AppGaps.md, AppGaps.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.inviteSheetTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppGaps.sm),
          TextField(decoration: InputDecoration(labelText: t.nameLabel, border: const OutlineInputBorder()), controller: nameCtrl),
          const SizedBox(height: AppGaps.sm),
          TextField(decoration: InputDecoration(labelText: t.relationLabel, border: const OutlineInputBorder()), controller: relationCtrl),
          const SizedBox(height: AppGaps.sm),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.sendInvite)));
            },
            icon: const Icon(Icons.send),
            label: Text(t.sendInvite),
          ),
        ],
      ),
    );
  }
}
