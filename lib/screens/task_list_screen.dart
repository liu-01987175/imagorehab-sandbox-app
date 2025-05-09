import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_tracker/services/api_service.dart';
import 'package:task_tracker/services/auth_service.dart';
import 'add_task_screen.dart';
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

  // Gets tasks from database
  Future<void> _loadTasks() async {
    const uri = 'http://localhost:3000/tasks';
    try {
      final response = await http.get(Uri.parse(uri));
      if (response.statusCode != 200)
        throw Exception('HTTP ${response.statusCode}');
      final List data = jsonDecode(response.body);
      final all =
          data.map((e) => model.Task.fromJson(e)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        tasks = all;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tasks';
        _loading = false;
      });
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      await ApiService.deleteTask(id);
      // remove locally after successful delete
      setState(() => tasks.removeWhere((t) => t.id == id));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  // Show edit dialog for a task
  void _showEditDialog(model.Task task) {
    final nameCtrl = TextEditingController(text: task.name);
    final descCtrl = TextEditingController(text: task.description);
    DateTime? pickedDate = task.date;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Edit Task'),
            content: StatefulBuilder(
              builder:
                  (ctx, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      TextButton(
                        child: Text(
                          pickedDate == null
                              ? 'No date chosen'
                              : '${pickedDate!.month}/${pickedDate!.day}/${pickedDate!.year}',
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: dialogContext,
                            initialDate: pickedDate!,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) setState(() => pickedDate = d);
                        },
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final updated = model.Task(
                    id: task.id,
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    date: pickedDate!,
                  );
                  await ApiService.updateTask(task.id, updated);
                  Navigator.of(dialogContext).pop();
                  _loadTasks(); // refresh list
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.greenAccent),
                    tooltip: 'Complete (delete)',
                    onPressed: () => _deleteTask(t.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                    tooltip: 'Edit Task',
                    onPressed: () => _showEditDialog(t),
                  ),
                ],
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
