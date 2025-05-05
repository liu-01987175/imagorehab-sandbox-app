// lib/screens/task_list_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> tasks = [];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // remove default back button
        title: const Text('Your Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Confirm Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
              );
              if (shouldSignOut == true) {
                await AuthService().signOut();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body:
          tasks.isEmpty
              ? const Center(
                child: Text(
                  'No tasks yet.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder:
                    (_, i) => ListTile(
                      title: Text(
                        tasks[i],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Checkbox(value: false, onChanged: (_) {}),
                    ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
