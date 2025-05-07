// lib/services/
import 'dart:convert';
import 'package:http/http.dart' as http;

class Task {
  final String id;
  final String name;
  final String description;
  final DateTime date;

  Task({
    this.id = '',
    required this.name,
    required this.description,
    required this.date,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Handle both cases: plain string or { "$oid": "…" }
    final rawId = json['_id'];
    String parsedId;
    if (rawId is Map && rawId.containsKey(r'$oid')) {
      parsedId = rawId[r'$oid'] as String;
    } else {
      parsedId = rawId.toString();
    }

    return Task(
      id: parsedId,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
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
