import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart'; // Import Task entity
import 'package:clarity/utils/app_colors.dart'; // Import AppColors

class TaskDetailDialog extends StatelessWidget {
  final Task task;

  const TaskDetailDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isDarkMode
                ? const Color(0xFF2D2D2D)
                : Colors.white, // Use pure white for light mode consistency
            borderRadius: BorderRadius.circular(
              20.0,
            ), // Increased border radius for modern look
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Close button in top-right corner
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        try {
                          if (context.mounted && Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          debugPrint('Error closing dialog: $e');
                        }
                      },
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Date and Time Section
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.greyColor,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Tanggal: ${DateFormat('d MMM yyyy', 'id_ID').format(task.dueDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (task.dueTime != null) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.greyColor,
                          size: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Waktu: ${task.dueTime!.format(context)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              // Recurrence Information Section
              if (task.isRecurring) ...[
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      task.recurrenceType.icon,
                      color: AppColors.infoColor,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Pengulangan: ${task.getDisplayNameWithInterval()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (task.recurrenceEndDate != null) ...[
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy,
                        color: AppColors.greyColor,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Berakhir: ${DateFormat('d MMM yyyy', 'id_ID').format(task.recurrenceEndDate!)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 16.0),
              if (task.description.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24.0),
              // Bottom action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      try {
                        if (context.mounted && Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        debugPrint('Error closing dialog: $e');
                      }
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
                      'Tutup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
