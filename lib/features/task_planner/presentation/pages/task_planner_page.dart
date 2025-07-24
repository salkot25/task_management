import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/task_provider.dart';
import 'package:myapp/utils/app_colors.dart'; // Import AppColors
import '../../domain/entities/task.dart'; // Corrected import path for Task entity
import '../widgets/task_detail_dialog.dart'; // Import the custom dialog

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
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Allow selecting past dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
        _focusedMonth = DateTime(picked.year, picked.month); // Update focused month when date is picked
      });
    }
  }

  void _addTask(BuildContext dialogContext) {
    if (_formKey.currentState!.validate()) {
      Provider.of<TaskProvider>(context, listen: false).addTask(
        _titleController.text,
        _descriptionController.text,
        _selectedDate,
      );
      _titleController.clear();
      _descriptionController.clear();
      if (mounted) {
        setState(() {
          // Keep the selected date as is after adding a task for it
        });
      }
      Navigator.of(dialogContext).pop();
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              onPressed: () => _addTask(dialogContext),
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetailsDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDetailDialog(task: task); // Use the custom dialog
      },
    );
  }

  // Helper to get the number of days in a month
  int _daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  // Helper to get the weekday of the first day of the month (1 for Monday, 7 for Sunday)
  int _firstWeekday(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }

 Widget _buildCalendar() {
    final int daysInMonth = _daysInMonth(_focusedMonth);
    final int firstWeekday = _firstWeekday(_focusedMonth); // 1 is Monday, 7 is Sunday
    final int emptyCells = firstWeekday - 1; // Number of empty cells before the 1st day

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // Use card color for the calendar background
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('M', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('W', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('F', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 1.0, // Make cells square
                ),
                itemCount: daysInMonth + emptyCells,
                itemBuilder: (context, index) {
                  if (index < emptyCells) {
                    return Container(); // Empty container for spacing
                  }
                  final int day = index - emptyCells + 1;
                  final DateTime currentDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                  final bool isSelected = currentDate.year == _selectedDate.year &&
                      currentDate.month == _selectedDate.month &&
                      currentDate.day == _selectedDate.day;

                  // Check for tasks on the current day
                  final tasksForDay = taskProvider.tasks.where((task) {
                     return task.dueDate.year == currentDate.year &&
                           task.dueDate.month == currentDate.month &&
                           task.dueDate.day == currentDate.day;
                  }).toList();

                  // Determine if all tasks are completed
                  final bool allTasksCompleted = tasksForDay.isNotEmpty &&
                      tasksForDay.every((task) => task.isCompleted);

                   // Determine if there are uncompleted tasks
                   final bool hasUncompletedTasks = tasksForDay.isNotEmpty &&
                      tasksForDay.any((task) => !task.isCompleted);

                  Color dayColor = Colors.transparent; // Default color
                   if (isSelected) {
                     dayColor = AppColors.primaryColor; // Selected date is always primary
                   } else if (allTasksCompleted) {
                     dayColor = AppColors.primaryColor.withOpacity(0.5); // Primary color for all completed tasks
                   } else if (hasUncompletedTasks) {
                     dayColor = AppColors.warningColor.withOpacity(0.5); // Warning color for uncompleted tasks
                   }


                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = currentDate;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: dayColor,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.greyLightColor),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            color: isSelected || allTasksCompleted ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isSelected || allTasksCompleted || hasUncompletedTasks ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(),
              const SizedBox(height: 24.0),
              Text(
                'Tasks for ${DateFormat('d MMMM yyyy').format(_selectedDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12.0),
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  // Filter tasks by selected date
                  final tasksForSelectedDate = taskProvider.tasks.where((task) {
                    // Compare dates without considering time
                    return task.dueDate.year == _selectedDate.year &&
                           task.dueDate.month == _selectedDate.month &&
                           task.dueDate.day == _selectedDate.day;
                  }).toList();


                  if (tasksForSelectedDate.isEmpty) {
                    return const Center(
                      child: Text('No tasks for this date.'),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Disable list scrolling
                      itemCount: tasksForSelectedDate.length,
                      itemBuilder: (context, index) {
                        final task = tasksForSelectedDate[index];
                        return ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              taskProvider.toggleTaskStatus(task.id);
                            },
                            activeColor: AppColors.primaryColor, // Apply primary color to checkbox
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                               color: task.isCompleted ? AppColors.greyColor : Theme.of(context).textTheme.bodyMedium?.color, // Dim completed tasks
                            ),
                          ),
                          subtitle: Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate)}', // Display due date as subtitle
                             style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: task.isCompleted ? AppColors.greyColor : Theme.of(context).textTheme.bodySmall?.color, // Dim completed tasks
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: AppColors.greyColor), // Info icon
                                onPressed: () {
                                  _showTaskDetailsDialog(task); // Show task details on info icon tap
                                },
                                tooltip: 'Task Details',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.greyColor), // Delete icon
                                onPressed: () {
                                  taskProvider.deleteTask(task.id);
                                },
                                tooltip: 'Delete Task',
                              ),
                            ],
                          ), // Use Row for multiple trailing icons
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
