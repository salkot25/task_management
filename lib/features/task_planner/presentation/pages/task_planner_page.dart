import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/task_provider.dart';

class TaskPlannerPage extends StatefulWidget {
  const TaskPlannerPage({super.key});

  @override
  _TaskPlannerPageState createState() => _TaskPlannerPageState();
}

class _TaskPlannerPageState extends State<TaskPlannerPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    // Check mounted before calling setState
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTask(BuildContext dialogContext) { // Pass dialog context
    if (_formKey.currentState!.validate()) {
      Provider.of<TaskProvider>(context, listen: false).addTask(
        _titleController.text,
        _descriptionController.text,
        _selectedDate,
      );
      _titleController.clear();
      _descriptionController.clear();
      // Check mounted before calling setState
      if (mounted) {
        setState(() {
          _selectedDate = DateTime.now(); // Reset date to today
        });
      }
      Navigator.of(dialogContext).pop(); // Close the dialog using dialog context
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Capture dialog context
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12.0),
                  ListTile(
                    title: Text('Due Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog using dialog context
              },
            ),
            ElevatedButton(
              onPressed: () => _addTask(dialogContext), // Pass dialog context to _addTask
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Planner'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Show a loading indicator while tasks are being fetched
          // This assumes your TaskProvider has a loading state or the initial stream is empty
          // if (taskProvider.isLoading) { // Uncomment if you add a loading state to TaskProvider
          //   return const Center(child: CircularProgressIndicator());
          // }

          if (taskProvider.tasks.isEmpty) {
             return const Center(
              child: Text('No tasks yet! Tap the + button to add one.'),
            );
          } else {
            return ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      taskProvider.toggleTaskStatus(task.id);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    '${task.description} - Due: ${DateFormat('MMM d, yyyy').format(task.dueDate)}',
                     style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                   // Optional: Add a delete icon
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                       taskProvider.deleteTask(task.id);
                    },
                    tooltip: 'Delete Task',
                  ),
                  // You can add onTap for editing the task if needed
                  // onTap: () { ... },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
