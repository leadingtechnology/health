import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

class TaskEditPage extends StatefulWidget {
  const TaskEditPage({super.key});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(hours: 4));
  final _notes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.taskEditTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(AppGaps.md, AppGaps.md, AppGaps.md, AppGaps.md),
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: t.taskTitleLabel, border: const OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? t.taskTitleRequired : null,
            ),
            const SizedBox(height: AppGaps.sm),
            ListTile(
              contentPadding: EdgeInsetsDirectional.zero,
              title: Text(t.taskDueLabel),
              subtitle: Text(_due.toString()),
              trailing: OutlinedButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _due,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) {
                    final pick = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_due));
                    if (pick != null) {
                      setState(() => _due = DateTime(d.year, d.month, d.day, pick.hour, pick.minute));
                    }
                  }
                },
                child: Text(t.select),
              ),
            ),
            const SizedBox(height: AppGaps.sm),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.taskNotesLabel, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: AppGaps.lg),
            FilledButton.icon(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  final item = TaskItem(id: UniqueKey().toString(), title: _title.text.trim(), due: _due, notes: _notes.text.trim());
                  context.read<AppState>().addTask(item);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(t.save),
            ),
          ],
        ),
      ),
    );
  }
}
