import 'package:flutter/material.dart';

enum Plan { free, standard, pro }
enum ModelTier { basic, enhanced, realtime }

class Message {
  final String id;
  final bool fromUser;
  final String text;
  final DateTime time;
  final List<String> actions; // e.g. ['set_task','export_pdf','share']

  Message({
    required this.id,
    required this.fromUser,
    required this.text,
    required this.time,
    this.actions = const [],
  });
}

class TaskItem {
  final String id;
  String title;
  DateTime due;
  bool done;
  String? notes;
  TaskItem({required this.id, required this.title, required this.due, this.done = false, this.notes});
}

class Member {
  final String id;
  final String name;
  final String relation; // e.g. 子女/护理员/医生
  final IconData icon;
  Member({required this.id, required this.name, required this.relation, this.icon = Icons.person_outline});
}
