import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart'; // Import Task entity
import 'package:clarity/utils/app_colors.dart'; // Import AppColors
import 'package:clarity/utils/navigation_helper_v2.dart' as nav;

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
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).cardColor, // Use card color for background
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ), // Modern title style
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.greyColor,
                    size: 20.0,
                  ), // Calendar icon
                  const SizedBox(width: 8.0),
                  Text(
                    'Tanggal Jatuh Tempo: ${DateFormat('d MMM yyyy', 'id_ID').format(task.dueDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color, // Use default text color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (task.description.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color, // Use default text color
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    nav.NavigationHelper.safePopDialog(context);
                  },
                  child: Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primaryColor,
                    ), // Use primary color for button
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
