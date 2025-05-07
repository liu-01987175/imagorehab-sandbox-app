// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:task_tracker/services/api_service.dart';
import 'package:task_tracker/services/auth_service.dart';
import 'add_task_screen.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart' as model;

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<model.Task> tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /*   Future<void> _loadTasks() async {
    try {
      final all = await ApiService.fetchTasks();
      all.sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        tasks = all;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tasks';
        _loading = false;
      });
    }
  } */

  Future<void> _loadTasks() async {
    const uri = 'http://localhost:3000/tasks';
    try {
      // Log before the call
      // ignore: avoid_print
      print('→ FETCHING tasks from $uri');

      final response = await http.get(Uri.parse(uri));

      // Log status & body
      // ignore: avoid_print
      print('← RESPONSE ${response.statusCode}: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final List data = jsonDecode(response.body);
      final all =
          data.map((e) => Task.fromJson(e)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        tasks = all;
        _loading = false;
        _error = null;
      });
    } catch (e, st) {
      // Log the full error & stack
      // ignore: avoid_print
      print('Error fetching tasks: $e\n$st');

      setState(() {
        _error = 'Failed to load tasks:\n$e';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    } else if (tasks.isEmpty) {
      body = const Center(
        child: Text(
          'No tasks yet.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final t = tasks[i];
          final formattedDate = '${t.date.month}/${t.date.day}/${t.date.year}';
          return Card(
            color: Colors.grey[850],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(t.name, style: const TextStyle(color: Colors.white)),
              trailing: Text(
                formattedDate,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (added == true) _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
