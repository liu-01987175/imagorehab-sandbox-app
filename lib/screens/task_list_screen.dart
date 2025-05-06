// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final all = await ApiService.fetchTasks();
    setState(() {
      tasks = all;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Tasks')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? const Center(
                child: Text(
                  'No tasks yet.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final t = tasks[i];
                  return ListTile(
                    title: Text(
                      t.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      t.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      '${t.date.month}/${t.date.day}/${t.date.year}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (added == true) {
            _loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
