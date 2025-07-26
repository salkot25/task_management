import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/core/sync/models/sync_item.dart';
import 'package:clarity/core/sync/helpers/offline_data_helper.dart';
import 'package:clarity/core/sync/widgets/sync_status_widget.dart';

/// Contoh implementasi TaskProvider dengan auto sync
///
/// Ini adalah contoh bagaimana mengintegrasikan auto sync
/// ke dalam provider yang sudah ada
class TaskProviderWithSync extends ChangeNotifier {
  // Existing task repository (uncomment dan gunakan sesuai implementasi Anda)
  // final dynamic _taskRepository;

  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TaskProviderWithSync();
  // Uncomment line berikut jika Anda menggunakan repository:
  // TaskProviderWithSync({required taskRepository}) : _taskRepository = taskRepository;

  /// Load tasks dengan offline fallback
  Future<void> loadTasks(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load offline data terlebih dahulu untuk UI yang responsif
      final offlineTasks = OfflineDataHelper.loadTasksOffline(context);
      if (offlineTasks.isNotEmpty) {
        _tasks = offlineTasks;
        notifyListeners();
      }

      // 2. Jika online, load data fresh dari backend
      if (OfflineDataHelper.isOnline(context)) {
        try {
          // Load dari backend (sesuaikan dengan implementasi repository Anda)
          final onlineTasks = await _loadTasksFromBackend();

          // Update local data
          _tasks = onlineTasks;

          // Simpan ke offline storage untuk next time
          for (final task in onlineTasks) {
            await OfflineDataHelper.saveTaskOffline(
              context: context,
              taskId: task['id'],
              taskData: task,
            );
          }

          notifyListeners();
        } catch (e) {
          // Jika gagal load online tapi ada offline data, tetap pakai offline
          if (offlineTasks.isEmpty) {
            _errorMessage = 'Failed to load tasks: $e';
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create task dengan auto sync
  Future<void> createTask({
    required BuildContext context,
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final taskId =
          taskData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      taskData['id'] = taskId;

      // 1. Tambahkan ke local list untuk UI immediate update
      _tasks.add(taskData);
      notifyListeners();

      // 2. Simpan offline
      await OfflineDataHelper.saveTaskOffline(
        context: context,
        taskId: taskId,
        taskData: taskData,
      );

      // 3. Jika online, coba simpan ke backend
      if (OfflineDataHelper.isOnline(context)) {
        try {
          await _createTaskInBackend(taskData);
          debugPrint('Task created online: $taskId');
        } catch (e) {
          // Jika gagal, tambah ke sync queue
          await OfflineDataHelper.addOperationToSync(
            context: context,
            entityType: SyncEntityType.task,
            operationType: SyncOperationType.create,
            data: taskData,
            customId: taskId,
          );
          debugPrint('Task creation failed, added to sync queue: $e');
        }
      } else {
        // Jika offline, langsung tambah ke sync queue
        await OfflineDataHelper.addOperationToSync(
          context: context,
          entityType: SyncEntityType.task,
          operationType: SyncOperationType.create,
          data: taskData,
          customId: taskId,
        );
        debugPrint('Task created offline, added to sync queue');
      }
    } catch (e) {
      _errorMessage = 'Failed to create task: $e';
      notifyListeners();
    }
  }

  /// Update task dengan auto sync
  Future<void> updateTask({
    required BuildContext context,
    required String taskId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      // 1. Update local list untuk UI immediate update
      final index = _tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        _tasks[index] = {..._tasks[index], ...updatedData};
        notifyListeners();
      }

      // 2. Simpan offline
      await OfflineDataHelper.saveTaskOffline(
        context: context,
        taskId: taskId,
        taskData: updatedData,
      );

      // 3. Jika online, coba update ke backend
      if (OfflineDataHelper.isOnline(context)) {
        try {
          await _updateTaskInBackend(taskId, updatedData);
          debugPrint('Task updated online: $taskId');
        } catch (e) {
          // Jika gagal, tambah ke sync queue
          await OfflineDataHelper.addOperationToSync(
            context: context,
            entityType: SyncEntityType.task,
            operationType: SyncOperationType.update,
            data: {'id': taskId, ...updatedData},
            customId: taskId,
          );
          debugPrint('Task update failed, added to sync queue: $e');
        }
      } else {
        // Jika offline, langsung tambah ke sync queue
        await OfflineDataHelper.addOperationToSync(
          context: context,
          entityType: SyncEntityType.task,
          operationType: SyncOperationType.update,
          data: {'id': taskId, ...updatedData},
          customId: taskId,
        );
        debugPrint('Task updated offline, added to sync queue');
      }
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  /// Delete task dengan auto sync
  Future<void> deleteTask({
    required BuildContext context,
    required String taskId,
  }) async {
    try {
      // 1. Remove dari local list untuk UI immediate update
      _tasks.removeWhere((task) => task['id'] == taskId);
      notifyListeners();

      // 2. Jika online, coba delete dari backend
      if (OfflineDataHelper.isOnline(context)) {
        try {
          await _deleteTaskFromBackend(taskId);
          debugPrint('Task deleted online: $taskId');
        } catch (e) {
          // Jika gagal, tambah ke sync queue
          await OfflineDataHelper.addOperationToSync(
            context: context,
            entityType: SyncEntityType.task,
            operationType: SyncOperationType.delete,
            data: {'id': taskId},
            customId: taskId,
          );
          debugPrint('Task deletion failed, added to sync queue: $e');
        }
      } else {
        // Jika offline, langsung tambah ke sync queue
        await OfflineDataHelper.addOperationToSync(
          context: context,
          entityType: SyncEntityType.task,
          operationType: SyncOperationType.delete,
          data: {'id': taskId},
          customId: taskId,
        );
        debugPrint('Task deleted offline, added to sync queue');
      }

      // 3. Remove dari offline storage
      // Implementasi tergantung pada storage structure Anda
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  /// Toggle task completion dengan auto sync
  Future<void> toggleTaskCompletion({
    required BuildContext context,
    required String taskId,
  }) async {
    try {
      // 1. Find dan toggle status di local list
      final index = _tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        final isCompleted = _tasks[index]['isCompleted'] ?? false;
        _tasks[index]['isCompleted'] = !isCompleted;
        _tasks[index]['completedAt'] = !isCompleted
            ? DateTime.now().toIso8601String()
            : null;
        notifyListeners();

        // 2. Update dengan auto sync
        await updateTask(
          context: context,
          taskId: taskId,
          updatedData: {
            'isCompleted': !isCompleted,
            'completedAt': !isCompleted
                ? DateTime.now().toIso8601String()
                : null,
          },
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle task completion: $e';
      notifyListeners();
    }
  }

  /// Get sync status untuk debugging
  void debugSyncStatus(BuildContext context) {
    final status = OfflineDataHelper.getSyncStatus(context);
    debugPrint('=== SYNC STATUS DEBUG ===');
    debugPrint('Connected: ${status['isConnected']}');
    debugPrint('Pending sync items: ${status['pending']}');
    debugPrint('Total sync items: ${status['total']}');
    debugPrint('Auto sync enabled: ${status['isAutoSyncEnabled']}');
    debugPrint('Last sync: ${status['lastSyncTime']}');
    if (status['lastSyncError'] != null) {
      debugPrint('Last error: ${status['lastSyncError']}');
    }
    debugPrint('========================');
  }

  // Placeholder methods - ganti dengan implementasi repository Anda
  Future<List<Map<String, dynamic>>> _loadTasksFromBackend() async {
    // TODO: Implement dengan actual repository
    throw UnimplementedError('Implement with your actual task repository');
  }

  Future<void> _createTaskInBackend(Map<String, dynamic> taskData) async {
    // TODO: Implement dengan actual repository
    throw UnimplementedError('Implement with your actual task repository');
  }

  Future<void> _updateTaskInBackend(
    String taskId,
    Map<String, dynamic> updatedData,
  ) async {
    // TODO: Implement dengan actual repository
    throw UnimplementedError('Implement with your actual task repository');
  }

  Future<void> _deleteTaskFromBackend(String taskId) async {
    // TODO: Implement dengan actual repository
    throw UnimplementedError('Implement with your actual task repository');
  }
}

/// Widget contoh untuk menampilkan tasks dengan sync status
class TaskListWithSyncWidget extends StatefulWidget {
  const TaskListWithSyncWidget({super.key});

  @override
  State<TaskListWithSyncWidget> createState() => _TaskListWithSyncWidgetState();
}

class _TaskListWithSyncWidgetState extends State<TaskListWithSyncWidget> {
  @override
  void initState() {
    super.initState();
    // Load tasks when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load tasks with your provider
      // Provider.of<TaskProviderWithSync>(context, listen: false).loadTasks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Sync status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SyncStatusWidget(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const SyncDetailsDialog(),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<TaskProviderWithSync>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadTasks(context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTasks(context),
            child: ListView.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return ListTile(
                  title: Text(task['title'] ?? 'No Title'),
                  subtitle: Text(task['description'] ?? 'No Description'),
                  leading: Checkbox(
                    value: task['isCompleted'] ?? false,
                    onChanged: (_) => provider.toggleTaskCompletion(
                      context: context,
                      taskId: task['id'],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.deleteTask(
                      context: context,
                      taskId: task['id'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show create task dialog
          _showCreateTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: const Text('Task creation dialog implementation here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create task implementation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
