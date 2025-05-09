import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_tracker/services/api_service.dart';
import 'package:task_tracker/services/auth_service.dart';
import 'add_task_screen.dart';
import '../services/api_service.dart' as model;

enum DateFilter { last7, last30, all }

/*
  todo:
  1. 
 */

extension DateFilterExt on DateFilter {
  String get label {
    switch (this) {
      case DateFilter.last7:
        return '7 days';
      case DateFilter.last30:
        return '30 days';
      case DateFilter.all:
      default:
        return 'All';
    }
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<model.Task> _allTasks = [];
  DateFilter _filter = DateFilter.last7;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    const uri = 'http://localhost:3000/tasks';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse(uri));
      if (response.statusCode != 200)
        throw Exception('HTTP ${response.statusCode}');
      final List data = jsonDecode(response.body);
      final all =
          data.map((e) => model.Task.fromJson(e)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        _allTasks = all;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tasks';
        _loading = false;
      });
    }
  }

  List<model.Task> get _filteredTasks {
    if (_filter == DateFilter.all) return _allTasks;

    // Compare only year/month/day so we ignore time‑of‑day mismatches
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.add(
      Duration(days: _filter == DateFilter.last7 ? 7 : 30),
    );
    return _allTasks.where((t) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      return (d.isAtSameMomentAs(today) || d.isAfter(today)) &&
          (d.isAtSameMomentAs(endDate) || d.isBefore(endDate));
    }).toList();
  }

  Future<void> _deleteTask(model.Task task) async {
    setState(() => _allTasks.removeWhere((t) => t.id == task.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() => _allTasks.add(task));
            _allTasks.sort((a, b) => a.date.compareTo(b.date));
          },
        ),
      ),
    );
    ApiService.deleteTask(task.id).catchError((_) {});
  }

  void _showEditDialog(model.Task task) {
    final nameCtrl = TextEditingController(text: task.name);
    final descCtrl = TextEditingController(text: task.description);
    DateTime pickedDate = task.date; // now non-nullable

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: pickedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) setState(() => pickedDate = d);
                        },
                        child: Text(
                          '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}',
                        ),
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final updated = model.Task(
                    id: task.id,
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    date: pickedDate, // now safe
                  );
                  await ApiService.updateTask(task.id, updated);
                  Navigator.of(ctx).pop();
                  _loadTasks();
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
    } else if (_filteredTasks.isEmpty) {
      body = const Center(
        child: Text(
          'No tasks in this range.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTasks.length,
        itemBuilder: (_, i) {
          final t = _filteredTasks[i];
          final formattedDate = '${t.date.month}/${t.date.day}/${t.date.year}';
          return Card(
            color: Colors.grey[850],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(t.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                formattedDate,
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.greenAccent),
                    tooltip: 'Complete',
                    onPressed: () => _deleteTask(t),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Delete',
                    onPressed: () => _deleteTask(t),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                    tooltip: 'Edit',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Show:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                DropdownButton<DateFilter>(
                  value: _filter,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  underline: Container(height: 1, color: Colors.white30),
                  items:
                      DateFilter.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _filter = v);
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(child: body),
        ],
      ),
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
