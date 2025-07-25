import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/task_provider.dart';
import 'package:myapp/utils/design_system/design_system.dart';
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
        _focusedMonth = DateTime(
          picked.year,
          picked.month,
        ); // Update focused month when date is picked
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          title: Text(
            'Add New Task',
            style: AppTypography.headlineSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: AppComponents.inputDecoration(
                      labelText: 'Task Title',
                      hintText: 'Enter task title',
                      prefixIcon: const Icon(Icons.task_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: AppComponents.inputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add task description',
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        'Due Date',
                        style: AppTypography.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        style: AppTypography.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: AppComponents.textButtonStyle(),
              child: Text(
                'Cancel',
                style: AppTypography.linkText.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _addTask(dialogContext),
              style: AppComponents.primaryButtonStyle(),
              child: Text('Add Task', style: AppTypography.buttonPrimary),
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
    var firstDayNextMonth = DateTime(
      firstDayThisMonth.year,
      firstDayThisMonth.month + 1,
      firstDayThisMonth.day,
    );
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  // Helper to get the weekday of the first day of the month (1 for Monday, 7 for Sunday)
  int _firstWeekday(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ==========================================
  // PROFESSIONAL UI COMPONENTS
  // ==========================================

  /// Professional Task Statistics Header
  Widget _buildTaskStatsHeader() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final today = DateTime.now();
        final todayTasks = taskProvider.tasks.where((task) {
          return task.dueDate.year == today.year &&
              task.dueDate.month == today.month &&
              task.dueDate.day == today.day;
        }).toList();

        final completedToday = todayTasks
            .where((task) => task.isCompleted)
            .length;
        final totalToday = todayTasks.length;
        final overdueTasks = taskProvider.tasks.where((task) {
          return task.dueDate.isBefore(today) && !task.isCompleted;
        }).length;

        return Container(
          padding: AppSpacing.cardPadding,
          decoration: AppComponents.cardDecoration().copyWith(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Progress',
                style: AppTypography.headlineSmall.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.today_outlined,
                      label: 'Today',
                      value: '$completedToday / $totalToday',
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.warning_outlined,
                      label: 'Overdue',
                      value: overdueTasks.toString(),
                      color: AppColors.errorColor,
                    ),
                  ),
                ],
              ),
              if (totalToday > 0) ...[
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: completedToday / totalToday,
                  backgroundColor: AppColors.greyExtraLightColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.successColor,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${((completedToday / totalToday) * 100).round()}% completed today',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Small Statistics Card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Professional Calendar Design
  Widget _buildProfessionalCalendar() {
    final int daysInMonth = _daysInMonth(_focusedMonth);
    final int firstWeekday = _firstWeekday(_focusedMonth);
    final int emptyCells = firstWeekday - 1;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          padding: AppSpacing.cardPadding,
          decoration: AppComponents.cardDecoration(),
          child: Column(
            children: [
              // Calendar Header with Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1,
                        );
                      });
                    },
                    style: AppComponents.textButtonStyle(),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: AppTypography.headlineSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                        );
                      });
                    },
                    style: AppComponents.textButtonStyle(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Weekday Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (day) => Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Text(
                          day,
                          style: AppTypography.labelMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: AppSpacing.xs,
                  mainAxisSpacing: AppSpacing.xs,
                  childAspectRatio: 1.0,
                ),
                itemCount: daysInMonth + emptyCells,
                itemBuilder: (context, index) {
                  if (index < emptyCells) {
                    return const SizedBox.shrink();
                  }

                  final int day = index - emptyCells + 1;
                  final DateTime currentDate = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month,
                    day,
                  );

                  return _buildCalendarDay(currentDate, taskProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Professional Calendar Day Cell
  Widget _buildCalendarDay(DateTime date, TaskProvider taskProvider) {
    final bool isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final bool isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    // Task analysis for the day
    final tasksForDay = taskProvider.tasks.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();

    final completedTasks = tasksForDay.where((task) => task.isCompleted).length;
    final totalTasks = tasksForDay.length;
    final hasOverdue = tasksForDay.any(
      (task) => !task.isCompleted && task.dueDate.isBefore(DateTime.now()),
    );

    // Determine colors based on task status
    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Theme.of(context).colorScheme.onSurface;

    if (isSelected) {
      backgroundColor = AppColors.primaryColor;
      textColor = AppColors.whiteColor;
    } else if (hasOverdue) {
      backgroundColor = AppColors.errorColor.withOpacity(0.1);
      borderColor = AppColors.errorColor;
    } else if (totalTasks > 0 && completedTasks == totalTasks) {
      backgroundColor = AppColors.successColor.withOpacity(0.1);
      borderColor = AppColors.successColor;
    } else if (totalTasks > 0) {
      backgroundColor = AppColors.warningColor.withOpacity(0.1);
      borderColor = AppColors.warningColor;
    }

    if (isToday && !isSelected) {
      borderColor = AppColors.primaryColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: borderColor ?? AppColors.greyExtraLightColor,
            width: borderColor != null ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: AppTypography.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (totalTasks > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.whiteColor
                        : AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Smart Task Sections with Professional Layout
  Widget _buildTaskSections() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final today = DateTime.now();
        final selectedDate = _selectedDate;

        // Categorize tasks
        final selectedDateTasks = taskProvider.tasks.where((task) {
          return task.dueDate.year == selectedDate.year &&
              task.dueDate.month == selectedDate.month &&
              task.dueDate.day == selectedDate.day;
        }).toList();

        final overdueTasks = taskProvider.tasks.where((task) {
          return task.dueDate.isBefore(today) && !task.isCompleted;
        }).toList();

        final upcomingTasks = taskProvider.tasks.where((task) {
          return task.dueDate.isAfter(today) &&
              task.dueDate.isBefore(today.add(const Duration(days: 7)));
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Tasks Overview',
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Priority Sections
            if (overdueTasks.isNotEmpty)
              _buildTaskSection(
                title: 'Overdue Tasks',
                subtitle: '${overdueTasks.length} tasks need attention',
                icon: Icons.warning_outlined,
                color: AppColors.errorColor,
                tasks: overdueTasks,
                showPriority: true,
              ),

            const SizedBox(height: AppSpacing.lg),

            _buildTaskSection(
              title: _isSameDay(selectedDate, today)
                  ? 'Today\'s Tasks'
                  : 'Tasks for ${DateFormat('MMM d').format(selectedDate)}',
              subtitle: '${selectedDateTasks.length} tasks scheduled',
              icon: Icons.today_outlined,
              color: AppColors.primaryColor,
              tasks: selectedDateTasks,
            ),

            if (upcomingTasks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildTaskSection(
                title: 'Upcoming This Week',
                subtitle: '${upcomingTasks.length} tasks coming up',
                icon: Icons.schedule_outlined,
                color: AppColors.infoColor,
                tasks: upcomingTasks,
              ),
            ],
          ],
        );
      },
    );
  }

  /// Professional Task Section Component
  Widget _buildTaskSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Task> tasks,
    bool showPriority = false,
  }) {
    if (tasks.isEmpty) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: AppComponents.cardDecoration().copyWith(
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(color: color),
                    ),
                    Text(
                      'No tasks',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.greyLightColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'All clear!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: AppComponents.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(color: color),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Task List
          ...tasks.map(
            (task) => _buildProfessionalTaskCard(task, showPriority),
          ),
        ],
      ),
    );
  }

  /// Professional Task Card Design
  Widget _buildProfessionalTaskCard(Task task, [bool showPriority = false]) {
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final isToday = _isSameDay(task.dueDate, DateTime.now());

    Color priorityColor = AppColors.greyLightColor;
    if (isOverdue) {
      priorityColor = AppColors.errorColor;
    } else if (isToday) {
      priorityColor = AppColors.warningColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? AppColors.greyExtraLightColor
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.greyLightColor
              : priorityColor.withOpacity(0.3),
        ),
        boxShadow: task.isCompleted
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).toggleTaskStatus(task.id);
            },
            activeColor: AppColors.successColor,
            side: BorderSide(color: priorityColor, width: 2),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.titleSmall.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? AppColors.greyColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: task.isCompleted
                          ? AppColors.greyColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: priorityColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      DateFormat('MMM d, yyyy').format(task.dueDate),
                      style: AppTypography.bodySmall.copyWith(
                        color: priorityColor,
                        fontWeight: isOverdue
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text(
                          'OVERDUE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => _showTaskDetailsDialog(task),
                tooltip: 'Task Details',
                style: AppComponents.textButtonStyle(),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.errorColor),
                onPressed: () {
                  Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).deleteTask(task.id);
                },
                tooltip: 'Delete Task',
                style: AppComponents.textButtonStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Task Planner',
          style: AppTypography.headlineMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.today_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedMonth = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.getPagePadding(screenWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Header with Stats
            _buildTaskStatsHeader(),
            const SizedBox(height: AppSpacing.lg),

            // Modern Calendar Design
            _buildProfessionalCalendar(),
            const SizedBox(height: AppSpacing.xl),

            // Smart Task Sections
            _buildTaskSections(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add_task),
        label: Text('Add Task', style: AppTypography.buttonPrimary),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
