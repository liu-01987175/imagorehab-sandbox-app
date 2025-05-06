import 'dart:convert';
import 'package:http/http.dart' as http;

// simple Task model
class Task {
  final String id;
  final String name, description;
  final DateTime date;
  Task({
    this.id = '',
    required this.name,
    required this.description,
    required this.date,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['_id']?['\$oid'] ?? json['_id']?.toString() ?? '',
    name: json['name'],
    description: json['description'],
    date: DateTime.parse(json['date']),
  );
}

class ApiService {
  static const _base = 'http://localhost:3000';

  // GET /tasks
  static Future<List<Task>> fetchTasks() async {
    final resp = await http.get(Uri.parse('$_base/tasks'));
    if (resp.statusCode != 200) throw Exception('Failed to load');
    final List data = jsonDecode(resp.body);
    return data.map((e) => Task.fromJson(e)).toList();
  }

  // POST /tasks
  static Future<void> addTask(Task t) async {
    final resp = await http.post(
      Uri.parse('$_base/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': t.name,
        'description': t.description,
        'date': t.date.toIso8601String(),
      }),
    );
    if (resp.statusCode != 200) throw Exception('Failed to add');
  }
}
