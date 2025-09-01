import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../l10n/gen/app_localizations.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tasks = state.tasks;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: tasks.isEmpty
          ? Center(child: Text(t.tasksEmpty))
          : ListView.separated(
              padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.sm, AppGaps.md, AppGaps.sm),
              itemBuilder: (ctx, i) {
                final item = tasks[i];
                return ListTile(
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(AppGaps.xs, 0, AppGaps.xs, 0),
                  leading: Checkbox(
                    value: item.done,
                    onChanged: (v) => context.read<AppState>().toggleTask(item.id, v ?? false),
                  ),
                  title: Text(item.title),
                  subtitle: Text(t.dueLabel(item.due)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(context).pushNamed('/tasks/edit'),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: tasks.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/tasks/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
