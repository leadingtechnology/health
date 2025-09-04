import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../l10n/gen/app_localizations.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tasks = state.tasks;
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
      child: Column(
        children: [
          // Header
          Container(
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
                  // Task icon
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
                      Icons.task_alt,
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
                          'My Tasks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${tasks.where((t) => !t.done).length} pending',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter button
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Show filter options
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Tasks list
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    icon: Icons.checklist_rounded,
                    title: t.tasksEmpty,
                    description: 'Start organizing your health tasks',
                    action: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/tasks/edit'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Task'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      final isOverdue = task.due.isBefore(DateTime.now()) && !task.done;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: task.done ? 0 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isOverdue
                                    ? theme.colorScheme.error.withOpacity(0.3)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            color: task.done
                                ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                                : theme.colorScheme.surface,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pushNamed('/tasks/edit'),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Checkbox with custom styling
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: task.done
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.outline,
                                          width: 2,
                                        ),
                                        color: task.done
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                      child: Checkbox(
                                        value: task.done,
                                        onChanged: (v) => context.read<AppState>().toggleTask(task.id, v ?? false),
                                        shape: const CircleBorder(),
                                        fillColor: WidgetStateProperty.all(Colors.transparent),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Task content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              decoration: task.done
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: task.done
                                                  ? theme.colorScheme.onSurfaceVariant
                                                  : null,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                size: 14,
                                                color: isOverdue
                                                    ? theme.colorScheme.error
                                                    : theme.colorScheme.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                t.dueLabel(task.due),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: isOverdue
                                                      ? theme.colorScheme.error
                                                      : theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Action buttons
                                    if (!task.done) ...[
                                      IconButton(
                                        icon: Icon(
                                          Icons.star_outline,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          // Toggle priority
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () {
                                          // Show options
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
