// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';

void main() => runApp(const TaskTrackerApp());

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginScreen(),
        '/signup': (ctx) => const SignUpScreen(),
        '/tasks': (ctx) => const TaskListScreen(),
        '/add': (ctx) => const AddTaskScreen(),
      },
    );
  }
}
