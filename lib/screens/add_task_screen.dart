import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/api_service.dart' as model;

/*
  todo:
  1. Stylize adding tasks in a card format afte pressing a button
  2. 
 */

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _pickedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_nameController.text.isEmpty ||
        _descController.text.isEmpty ||
        _pickedDate == null)
      return;

    final task = model.Task(
      name: _nameController.text,
      description: _descController.text,
      date: _pickedDate!,
    );

    await ApiService.addTask(task);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pickedDate == null
                        ? 'No date chosen'
                        : '${_pickedDate!.month}/${_pickedDate!.day}/${_pickedDate!.year}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setState(() => _pickedDate = d);
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
