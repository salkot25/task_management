import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/task_provider.dart';
import 'package:clarity/utils/design_system/design_system.dart';
import '../../domain/entities/task.dart'; // Corrected import path for Task entity
import '../widgets/task_detail_dialog.dart'; // Import the custom dialog
import 'package:clarity/presentation/widgets/standard_app_bar.dart';
import 'package:clarity/utils/navigation_helper_v2.dart' as nav;

class TaskPlannerPage extends StatefulWidget {
  const TaskPlannerPage({super.key});

  @override
  _TaskPlannerPageState createState() => _TaskPlannerPageState();
}

class _TaskPlannerPageState extends State<TaskPlannerPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  late DateTime _focusedMonth;
  late AnimationController _blinkAnimationController;
  late Animation<double> _blinkAnimation;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  // Indonesian date formatters
  final DateFormat _indonesianDateFormat = DateFormat(
    'EEEE, d MMMM yyyy',
    'id_ID',
  );
  final DateFormat _indonesianShortDateFormat = DateFormat(
    'd MMM yyyy',
    'id_ID',
  );
  final DateFormat _indonesianMonthFormat = DateFormat('MMMM', 'id_ID');
  final DateFormat _indonesianYearFormat = DateFormat('yyyy', 'id_ID');
  final DateFormat _indonesianDayFormat = DateFormat('d MMM', 'id_ID');

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();

    // Initialize blink animation for overdue tasks
    _blinkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _blinkAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize progress animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start the blinking animation
    _blinkAnimationController.repeat(reverse: true);

    // Start progress animation
    _progressAnimationController.forward();
  }

  Future<void> _showRecurrenceDialog(
    BuildContext context,
    StateSetter setDialogState,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Pengulangan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: RecurrenceType.values.map((type) {
                return RadioListTile<RecurrenceType>(
                  title: Row(
                    children: [
                      Icon(type.icon, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  value: type,
                  groupValue: _selectedRecurrence,
                  onChanged: (RecurrenceType? value) async {
                    if (value != null) {
                      if (value == RecurrenceType.customDays) {
                        // Show interval selection dialog for custom days
                        final interval = await _showCustomIntervalDialog(
                          context,
                        );
                        if (interval != null) {
                          setState(() {
                            _selectedRecurrence = value;
                            _recurrenceInterval = interval;
                          });
                          setDialogState(() {
                            // Update dialog state as well
                          });
                        }
                      } else {
                        setState(() {
                          _selectedRecurrence = value;
                          _recurrenceInterval = 1; // Reset to default
                        });
                        setDialogState(() {
                          // Update dialog state as well
                        });
                      }
                      Navigator.of(context).pop();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<int?> _showCustomIntervalDialog(BuildContext context) async {
    int selectedInterval = _recurrenceInterval;
    final TextEditingController intervalController = TextEditingController(
      text: selectedInterval.toString(),
    );

    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Interval Hari'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Berapa hari sekali tugas ini berulang?'),
              const SizedBox(height: 16),
              TextFormField(
                controller: intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Hari',
                  hintText: 'Contoh: 4 (untuk 4 hari sekali)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed >= 1 && parsed <= 365) {
                    selectedInterval = parsed;
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Rentang: 1-365 hari',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(intervalController.text);
                if (value != null && value >= 1 && value <= 365) {
                  Navigator.of(context).pop(value);
                } else {
                  // Show error or default to current value
                  Navigator.of(context).pop(selectedInterval);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(BuildContext dialogContext) {
    if (_formKey.currentState!.validate()) {
      Provider.of<TaskProvider>(context, listen: false).addTask(
        _titleController.text,
        _descriptionController.text,
        _selectedDate,
        _selectedTime,
        recurrenceType: _selectedRecurrence,
        recurrenceInterval: _recurrenceInterval,
        recurrenceEndDate: _recurrenceEndDate,
      );
      _titleController.clear();
      _descriptionController.clear();

      // Reset recurrence settings
      _selectedRecurrence = RecurrenceType.none;
      _recurrenceInterval = 1;
      _recurrenceEndDate = null;

      // Restart progress animation when task is added
      _restartProgressAnimation();

      // Don't change the selected date - keep it as is for user convenience
      nav.NavigationHelper.safePopDialog(dialogContext);
    }
  }

  void _showAddTaskDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    nav.NavigationHelper.safeShowDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : Colors.white, // Gunakan putih murni untuk dialog
              surfaceTintColor: isDarkMode
                  ? Colors.transparent
                  : Colors.transparent, // Hapus surface tint untuk mode light
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: isDarkMode ? 8 : 4,
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_task_rounded,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Tugas Baru',
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Buat tugas untuk ${_indonesianDayFormat.format(_selectedDate)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      // Enhanced Title Field
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration:
                            AppComponents.inputDecoration(
                              labelText: 'Judul Tugas',
                              hintText: 'Masukkan judul tugas',
                              prefixIcon: Icon(
                                Icons.task_outlined,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              colorScheme: Theme.of(context).colorScheme,
                            ).copyWith(
                              filled: true,
                              fillColor: isDarkMode
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                            ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan judul tugas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Enhanced Description Field
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration:
                            AppComponents.inputDecoration(
                              labelText: 'Deskripsi (Opsional)',
                              hintText: 'Tambahkan deskripsi tugas',
                              prefixIcon: Icon(
                                Icons.description_outlined,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              colorScheme: Theme.of(context).colorScheme,
                            ).copyWith(
                              filled: true,
                              fillColor: isDarkMode
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                            ),
                        maxLines: 3,
                        minLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Enhanced Date Picker
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Tanggal Jatuh Tempo',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _indonesianDateFormat.format(_selectedDate),
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.edit_calendar_outlined,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            size: 20,
                          ),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                                _focusedMonth = DateTime(
                                  picked.year,
                                  picked.month,
                                );
                              });
                              setDialogState(() {
                                // Update dialog state as well
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Enhanced Time Picker
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.access_time_outlined,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Waktu (Opsional)',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Ketuk untuk mengatur waktu',
                            style: AppTypography.bodyMedium.copyWith(
                              color: _selectedTime != null
                                  ? (isDarkMode ? Colors.white : Colors.black87)
                                  : (isDarkMode
                                        ? Colors.grey[500]
                                        : Colors.grey[500]),
                              fontWeight: _selectedTime != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedTime != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTime = null;
                                    });
                                    setDialogState(() {
                                      // Update dialog state as well
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.grey.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.clear,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      size: 16,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.schedule_outlined,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedTime = picked;
                              });
                              setDialogState(() {
                                // Update dialog state as well
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Enhanced Recurrence Picker
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _selectedRecurrence.icon,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Pengulangan',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _selectedRecurrence == RecurrenceType.customDays
                                ? 'Setiap $_recurrenceInterval Hari'
                                : _selectedRecurrence.displayName,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            size: 20,
                          ),
                          onTap: () async {
                            await _showRecurrenceDialog(
                              context,
                              setDialogState,
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                // Enhanced Cancel Button
                TextButton(
                  onPressed: () {
                    // Clear the form controllers when canceling
                    _titleController.clear();
                    _descriptionController.clear();
                    // Don't reset the selected date - keep user's selection
                    // Close the dialog
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Enhanced Add Button
                ElevatedButton(
                  onPressed: () => _addTask(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Tambah Tugas',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskDetailsDialog(Task task) {
    nav.NavigationHelper.safeShowDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDetailDialog(task: task); // Use the custom dialog
      },
    );
  }

  Future<void> _showDeleteRecurringTaskDialog(Task task) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Tugas Berulang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tugas "${task.title}" adalah tugas berulang.'),
              const SizedBox(height: 16),
              const Text('Pilih opsi penghapusan:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).deleteTask(task.id);
                Navigator.of(context).pop();
              },
              child: const Text('Hapus Hanya Ini'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).deleteRecurringTask(task.id, deleteAllInstances: true);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to restart progress animation
  void _restartProgressAnimation() {
    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  // Show success dialog for no overdue tasks
  void _showNoOverdueTasksSuccessDialog() {
    nav.NavigationHelper.safeShowDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: isDarkMode ? 8 : 4,
          titlePadding: const EdgeInsets.all(AppSpacing.lg),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tidak Ada Tugas Terlambat',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Semua tugas Anda up to date',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),

              // Minimalist Success Illustration
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.successColor.withOpacity(0.1),
                      AppColors.primaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.successColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 35,
                      color: AppColors.successColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Success Message
              Text(
                'Sempurna! 🎯',
                style: AppTypography.headlineSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Anda memiliki manajemen waktu yang baik! Tidak ada tugas yang terlambat dan semua berjalan sesuai jadwal.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action Suggestion
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.successColor.withOpacity(0.05),
                      AppColors.primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.successColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: AppColors.successColor,
                      size: 24,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tetap Konsisten',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pertahankan disiplin waktu yang baik ini untuk produktivitas optimal!',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.thumb_up_rounded, size: 18),
              label: Text(
                'Mantap!',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  // Get overdue tasks count
  int _getOverdueTasksCount(TaskProvider taskProvider) {
    final today = DateTime.now();
    return taskProvider.tasks.where((task) {
      return task.dueDate.isBefore(today) && !task.isCompleted;
    }).length;
  }

  // Show overdue tasks notification dialog
  void _showOverdueTasksDialog(TaskProvider taskProvider) {
    final today = DateTime.now();
    final overdueTasks = taskProvider.tasks.where((task) {
      return task.dueDate.isBefore(today) && !task.isCompleted;
    }).toList();

    if (overdueTasks.isEmpty) {
      nav.NavigationHelper.safeShowDialog(
        context: context,
        builder: (BuildContext context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color(0xFF2D2D2D)
                : Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: isDarkMode ? 8 : 4,
            titlePadding: const EdgeInsets.all(AppSpacing.lg),
            contentPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            actionsPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tidak Ada Tugas Terlambat',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.successColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Semua tugas Anda up to date',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),

                // Minimalist Success Illustration
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.successColor.withOpacity(0.1),
                        AppColors.primaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        size: 35,
                        color: AppColors.successColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Success Message
                Text(
                  'Sempurna! 🎯',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Anda memiliki manajemen waktu yang baik! Tidak ada tugas yang terlambat dan semua berjalan sesuai jadwal.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Action Suggestion
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.successColor.withOpacity(0.05),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.successColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: AppColors.successColor,
                        size: 24,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tetap Konsisten',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.successColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Pertahankan disiplin waktu yang baik ini untuk produktivitas optimal!',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.thumb_up_rounded, size: 18),
                label: Text(
                  'Mantap!',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    nav.NavigationHelper.safeShowDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;

                // Re-calculate overdue tasks in case status changed
                final currentOverdueTasks = taskProvider.tasks.where((task) {
                  return task.dueDate.isBefore(today) && !task.isCompleted;
                }).toList();

                // Check if all overdue tasks are now completed
                if (currentOverdueTasks.isEmpty) {
                  // Auto-close current dialog and show success dialog
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _showNoOverdueTasksSuccessDialog();
                    }
                  });

                  return const SizedBox.shrink(); // Return empty widget
                }

                return AlertDialog(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: isDarkMode ? 8 : 4,
                  titlePadding: const EdgeInsets.all(AppSpacing.lg),
                  contentPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.warning_outlined,
                          color: AppColors.errorColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tugas Terlambat',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.errorColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${currentOverdueTasks.length} tugas memerlukan perhatian',
                              style: AppTypography.bodySmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: currentOverdueTasks.length,
                        itemBuilder: (context, index) {
                          return _buildProfessionalTaskCardWithCallback(
                            currentOverdueTasks[index],
                            true,
                            onStatusChanged: () {
                              // Update dialog state when task status changes
                              setDialogState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Scroll to overdue tasks section
                        _restartProgressAnimation();
                      },
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(
                        'Lihat Semua',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
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
    _blinkAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  // ==========================================
  // PROFESSIONAL UI COMPONENTS
  // ==========================================

  /// Minimalist Task Statistics Header with Professional Layout
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

        // Smart Progress Logic - Show Real Progress & Motivate Users
        final allTasks = taskProvider.tasks.length;
        final completedAllTasks = taskProvider.tasks
            .where((task) => task.isCompleted)
            .length;

        // Display Strategy:
        // 1. If no tasks at all: Show "Mulai dengan membuat tugas pertama"
        // 2. If all tasks completed: Show "Semua Selesai! 🎉"
        // 3. If has tasks: Show actual progress (completed/total)
        final bool hasNoTasks = allTasks == 0;
        final bool isAllCompleted =
            allTasks > 0 && completedAllTasks == allTasks;
        final bool hasActiveTasks = allTasks > 0 && !isAllCompleted;

        // Progress values for display
        final int displayCompleted = hasActiveTasks
            ? completedAllTasks
            : (isAllCompleted ? allTasks : 0);
        final int displayTotal = hasActiveTasks
            ? allTasks
            : (isAllCompleted ? allTasks : 0);
        final double progressValue = hasNoTasks
            ? 0.0
            : (allTasks > 0 ? completedAllTasks / allTasks : 0.0);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2D2D2D)
                : Colors.white, // Gunakan putih murni untuk mode light
            borderRadius: BorderRadius.circular(AppComponents.largeRadius),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(
                        0.15,
                      ), // Shadow lebih gelap dan jelas
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Main Progress Indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progres Tugas',
                          style: AppTypography.labelMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hasNoTasks ? '0' : '$displayCompleted',
                              style: AppTypography.headlineLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              hasNoTasks ? ' / 0' : ' / $displayTotal',
                              style: AppTypography.titleMedium.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Enhanced Progress Bar with Animation
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                final animatedProgress =
                                    progressValue * _progressAnimation.value;

                                return LinearProgressIndicator(
                                  value: animatedProgress,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isAllCompleted
                                        ? AppColors.successColor
                                        : (hasActiveTasks &&
                                                  displayCompleted > 0
                                              ? AppColors.primaryColor
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest),
                                  ),
                                  minHeight: 8,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  // Enhanced Circular Progress with Animation
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      children: [
                        // Background circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode
                                ? Colors.grey.withOpacity(0.2)
                                : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.3),
                          ),
                        ),
                        // Animated Progress circle
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              final animatedProgress =
                                  progressValue * _progressAnimation.value;

                              return CircularProgressIndicator(
                                value: animatedProgress,
                                strokeWidth: 4,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isAllCompleted
                                      ? AppColors.successColor
                                      : (hasActiveTasks && displayCompleted > 0
                                            ? AppColors.primaryColor
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest),
                                ),
                              );
                            },
                          ),
                        ),
                        // Percentage text
                        Center(
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              final targetPercentage = isAllCompleted
                                  ? 100
                                  : (displayTotal > 0
                                        ? ((displayCompleted / displayTotal) *
                                                  100)
                                              .round()
                                        : 0);
                              final animatedPercentage =
                                  (targetPercentage * _progressAnimation.value)
                                      .round();

                              return Text(
                                '$animatedPercentage%',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMinimalistStatItem(
                      icon: Icons.today_rounded,
                      value: '$completedToday / $totalToday',
                      label: 'Hari Ini',
                      color: AppColors.primaryColor,
                      isActive: totalToday > 0,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildMinimalistStatItem(
                      icon: Icons.warning_rounded,
                      value: overdueTasks.toString(),
                      label: 'Terlambat',
                      color: AppColors.errorColor,
                      isActive: overdueTasks > 0,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildMinimalistStatItem(
                      icon: Icons.check_circle_rounded,
                      value: completedAllTasks.toString(),
                      label: 'Selesai',
                      color: AppColors.successColor,
                      isActive: completedAllTasks > 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Minimalist Statistics Item Design
  Widget _buildMinimalistStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isActive = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withOpacity(0.1)
                  : isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: isActive
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Professional Calendar Design with Minimalist Approach
  Widget _buildProfessionalCalendar() {
    final int daysInMonth = _daysInMonth(_focusedMonth);
    final int firstWeekday = _firstWeekday(_focusedMonth);
    // Senin=1 needs 0 empty cells, Selasa=2 needs 1 empty cell, etc.
    final int emptyCells = firstWeekday - 1;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2D2D2D)
                : Colors.white, // Gunakan putih murni untuk calendar
            borderRadius: BorderRadius.circular(AppComponents.largeRadius),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(
                        0.15,
                      ), // Shadow lebih gelap dan jelas untuk calendar
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Minimalist Calendar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.withOpacity(0.2)
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        });
                      },
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _indonesianMonthFormat.format(_focusedMonth),
                        style: AppTypography.headlineSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _indonesianYearFormat.format(_focusedMonth),
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.withOpacity(0.2)
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
                      },
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Clean Weekday Headers (Indonesian) - Corrected order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    [
                          'Sen', // Senin (Monday)
                          'Sel', // Selasa (Tuesday)
                          'Rab', // Rabu (Wednesday)
                          'Kam', // Kamis (Thursday)
                          'Jum', // Jumat (Friday)
                          'Sab', // Sabtu (Saturday)
                          'Min', // Minggu (Sunday)
                        ] // Senin, Selasa, Rabu, Kamis, Jumat, Sabtu, Minggu
                        .map(
                          (day) => Container(
                            width: 36,
                            height: 28,
                            alignment: Alignment.center,
                            child: Text(
                              day,
                              style: AppTypography.labelMedium.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Minimalist Calendar Grid
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

                  return _buildMinimalistCalendarDay(currentDate, taskProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Minimalist Calendar Day Cell with Clean Design
  Widget _buildMinimalistCalendarDay(DateTime date, TaskProvider taskProvider) {
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

    // Clean color system
    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Theme.of(context).colorScheme.onSurface;

    if (isSelected) {
      backgroundColor = AppColors.primaryColor;
      textColor = AppColors.whiteColor;
      borderColor = AppColors.primaryColor;
    } else if (hasOverdue) {
      backgroundColor = AppColors.errorColor.withOpacity(0.08);
      borderColor = AppColors.errorColor.withOpacity(0.3);
      textColor = AppColors.errorColor;
    } else if (totalTasks > 0 && completedTasks == totalTasks) {
      backgroundColor = AppColors.successColor.withOpacity(0.08);
      borderColor = AppColors.successColor.withOpacity(0.3);
      textColor = AppColors.successColor;
    } else if (totalTasks > 0) {
      backgroundColor = AppColors.primaryColor.withOpacity(0.08);
      borderColor = AppColors.primaryColor.withOpacity(0.3);
      textColor = AppColors.primaryColor;
    }

    if (isToday && !isSelected) {
      borderColor = AppColors.primaryColor.withOpacity(0.6);
    }

    // Build the minimalist calendar day widget
    Widget calendarDayWidget = GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: borderColor != null ? 1.5 : 0,
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
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            // Task indicator dot
            if (totalTasks > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.whiteColor
                        : (hasOverdue
                              ? AppColors.errorColor
                              : (completedTasks == totalTasks
                                    ? AppColors.successColor
                                    : AppColors.primaryColor)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // Add subtle animation for overdue tasks
    if (hasOverdue && !isSelected) {
      return AnimatedBuilder(
        animation: _blinkAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.errorColor.withOpacity(
                    0.5 * _blinkAnimation.value, // Shadow animasi lebih kuat
                  ),
                  blurRadius: 12 * _blinkAnimation.value,
                  spreadRadius: 3 * _blinkAnimation.value,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: calendarDayWidget,
          );
        },
      );
    }

    return calendarDayWidget;
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

        final upcomingTasks = taskProvider.tasks.where((task) {
          return task.dueDate.isAfter(today) &&
              task.dueDate.isBefore(today.add(const Duration(days: 7)));
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Ringkasan Tugas',
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            _buildTaskSection(
              title: _isSameDay(selectedDate, today)
                  ? 'Tugas Hari Ini'
                  : 'Tugas untuk ${_indonesianShortDateFormat.format(selectedDate)}',
              subtitle: '${selectedDateTasks.length} tugas terjadwal',
              icon: Icons.today_outlined,
              color: AppColors.primaryColor,
              tasks: selectedDateTasks,
            ),

            if (upcomingTasks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildTaskSection(
                title: 'Tugas Mendatang Minggu Ini',
                subtitle: '${upcomingTasks.length} tugas akan datang',
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2D2D2D)
              : Colors.white, // Gunakan putih murni untuk task section
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey.withOpacity(0.2)
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(
                      0.12,
                    ), // Shadow lebih gelap untuk task section
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tidak ada tugas terjadwal',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Minimalist Success Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.successColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 40,
                    color: AppColors.successColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Success Message
            Text(
              'Semua Beres! 🎉',
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Anda sudah menyelesaikan semua tugas. Saatnya istirahat atau merencanakan ke depan!',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Action Suggestion
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.05),
                    AppColors.secondaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tips Produktif',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Hari yang terorganisir dimulai dengan perencanaan yang jelas. Gunakan tombol + untuk menambahkan tugas selanjutnya!',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors
                  .white, // Gunakan putih murni untuk task section dengan tasks
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(
                    0.12,
                  ), // Shadow lebih gelap untuk task section dengan tasks
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
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

  /// Professional Task Card Design with Modern Aesthetic
  Widget _buildProfessionalTaskCard(Task task, [bool showPriority = false]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final isToday = _isSameDay(task.dueDate, DateTime.now());

    Color priorityColor = Theme.of(context).colorScheme.onSurfaceVariant;
    if (isOverdue) {
      priorityColor = AppColors.errorColor;
    } else if (isToday) {
      priorityColor = AppColors.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3))
            : (isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : Colors.white), // Gunakan putih murni untuk task card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? Colors.transparent
              : (isOverdue
                    ? AppColors.errorColor.withOpacity(0.2)
                    : (isDarkMode
                          ? Colors.grey.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.1))),
          width: 1,
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: isOverdue
                      ? AppColors.errorColor.withOpacity(
                          0.25,
                        ) // Shadow lebih kuat untuk overdue
                      : (isDarkMode
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(
                                0.1,
                              )), // Shadow lebih gelap untuk task card
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Checkbox with better design
          GestureDetector(
            onTap: () {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).toggleTaskStatus(task.id);
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.successColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.successColor
                      : priorityColor.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                Text(
                  task.title,
                  style: AppTypography.titleMedium.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),

                // Task Description
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    task.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: task.isCompleted
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // Date and Time Row - Using Wrap to handle overflow
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    // Date with icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: priorityColor,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _indonesianDayFormat.format(task.dueDate),
                            style: AppTypography.labelMedium.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time with icon (if available)
                    if (task.dueTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: priorityColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              task.dueTime!.format(context),
                              style: AppTypography.labelMedium.copyWith(
                                color: priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Recurrence indicator (if recurring)
                    if (task.isRecurring)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.recurrenceType.icon,
                              size: 14,
                              color: AppColors.infoColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              task.getShortNameWithInterval(),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.infoColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Status Badge
                    if (isOverdue && !task.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Terlambat',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      )
                    else if (isToday && !task.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Hari Ini',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      )
                    else if (task.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Done',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.successColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Actions Menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onSelected: (value) {
              switch (value) {
                case 'details':
                  _showTaskDetailsDialog(task);
                  break;
                case 'delete':
                  if (task.isRecurring) {
                    _showDeleteRecurringTaskDialog(task);
                  } else {
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).deleteTask(task.id);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Detail',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Hapus',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: Theme.of(context).colorScheme.surface,
          ),
        ],
      ),
    );
  }

  /// Professional Task Card with Callback for Dialog Updates
  Widget _buildProfessionalTaskCardWithCallback(
    Task task,
    bool showPriority, {
    VoidCallback? onStatusChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final isToday = _isSameDay(task.dueDate, DateTime.now());

    Color priorityColor = Theme.of(context).colorScheme.onSurfaceVariant;
    if (isOverdue) {
      priorityColor = AppColors.errorColor;
    } else if (isToday) {
      priorityColor = AppColors.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3))
            : (isDarkMode ? const Color(0xFF2D2D2D) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? Colors.transparent
              : (isOverdue
                    ? AppColors.errorColor.withOpacity(0.2)
                    : (isDarkMode
                          ? Colors.grey.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.1))),
          width: 1,
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: isOverdue
                      ? AppColors.errorColor.withOpacity(0.25)
                      : (isDarkMode
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.1)),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Checkbox with callback
          GestureDetector(
            onTap: () {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).toggleTaskStatus(task.id);

              // Call the callback to update dialog state
              if (onStatusChanged != null) {
                onStatusChanged();
              }
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.successColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.successColor
                      : priorityColor.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with modern typography
                Text(
                  task.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: task.isCompleted
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: task.isCompleted
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Enhanced Date and Time Display
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _indonesianDayFormat.format(task.dueDate),
                            style: AppTypography.labelSmall.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (task.dueTime != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '•',
                              style: AppTypography.labelSmall.copyWith(
                                color: priorityColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueTime!.format(context),
                              style: AppTypography.labelSmall.copyWith(
                                color: priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (showPriority && isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Terlambat',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.errorColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1A1A)
          : Theme.of(context).colorScheme.surface,
      appBar: StandardAppBar(
        title: 'Task Planner',
        subtitle: 'Organize your daily workflow',
        actions: [
          // Notification button for overdue tasks
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final overdueCount = _getOverdueTasksCount(taskProvider);

              return Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.withOpacity(0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    ActionButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () => _showOverdueTasksDialog(taskProvider),
                      tooltip: overdueCount > 0
                          ? 'Tugas Terlambat ($overdueCount)'
                          : 'Notifikasi Tugas',
                    ),
                    if (overdueCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            overdueCount > 99 ? '99+' : overdueCount.toString(),
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          // Add Task Button
          ActionButton(
            icon: Icons.add_rounded,
            onPressed: _showAddTaskDialog,
            tooltip: 'Tambah Tugas',
            color: AppColors.successColor,
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Show error message if there's an error
          if (taskProvider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(taskProvider.error!),
                  backgroundColor: AppColors.errorColor,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      taskProvider.clearError();
                    },
                  ),
                ),
              );
              taskProvider.clearError();
            });
          }

          // Check authentication status
          if (!taskProvider.isAuthenticated) {
            return _buildAuthenticationRequired();
          }

          // Show loading state
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return _buildLoadingState();
          }

          return SingleChildScrollView(
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
          );
        },
      ),
    );
  }

  /// Widget for authentication required state
  Widget _buildAuthenticationRequired() {
    return Center(
      child: Container(
        margin: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.12,
              ), // Shadow lebih gelap untuk authentication widget
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.warningColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Autentikasi Diperlukan',
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Harap masuk untuk mengakses perencana tugas dan mengelola tugas Anda.',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login page
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('Masuk'),
              style: AppComponents.primaryButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget for loading state
  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Memuat tugas Anda...',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
