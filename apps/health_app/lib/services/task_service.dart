import 'dart:convert';
import 'api_service.dart';
import '../models/models.dart';

class TaskService {
  final ApiService _api = ApiService();
  
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();
  
  Future<List<TaskItem>> getTasks({bool? isDone, String? patientId}) async {
    try {
      String endpoint = '/tasks';
      final params = <String, String>{};
      if (isDone != null) params['isDone'] = isDone.toString();
      if (patientId != null) params['patientId'] = patientId;
      
      if (params.isNotEmpty) {
        endpoint += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }
      
      final response = await _api.get(endpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => TaskItem(
          id: item['id'],
          title: item['title'],
          due: DateTime.parse(item['dueAt']),
          done: item['isDone'] ?? false,
          notes: item['notes'],
        )).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }
  
  Future<TaskItem> createTask({
    required String title,
    required DateTime dueAt,
    String? notes,
    String? category,
    String? patientId,
  }) async {
    try {
      final response = await _api.post('/tasks', {
        'title': title,
        'dueAt': dueAt.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (category != null) 'category': category,
        if (patientId != null) 'patientId': patientId,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return TaskItem(
          id: data['id'],
          title: data['title'],
          due: DateTime.parse(data['dueAt']),
          done: data['isDone'] ?? false,
          notes: data['notes'],
        );
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }
  
  Future<TaskItem> updateTask({
    required String id,
    required String title,
    required DateTime dueAt,
    String? notes,
    String? category,
    String? patientId,
  }) async {
    try {
      final response = await _api.put('/tasks/$id', {
        'title': title,
        'dueAt': dueAt.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (category != null) 'category': category,
        if (patientId != null) 'patientId': patientId,
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaskItem(
          id: data['id'],
          title: data['title'],
          due: DateTime.parse(data['dueAt']),
          done: data['isDone'] ?? false,
          notes: data['notes'],
        );
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }
  
  Future<TaskItem> toggleTask(String id) async {
    try {
      final response = await _api.post('/tasks/$id/toggle', {});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaskItem(
          id: data['id'],
          title: data['title'],
          due: DateTime.parse(data['dueAt']),
          done: data['isDone'] ?? false,
          notes: data['notes'],
        );
      } else {
        throw Exception('Failed to toggle task');
      }
    } catch (e) {
      throw Exception('Error toggling task: $e');
    }
  }
  
  Future<void> deleteTask(String id) async {
    try {
      final response = await _api.delete('/tasks/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}