import 'dart:io';

import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService;
  List<Task> _tasks = [];
  bool _isLoading = false;
  Task? _currentTask;
  String? _error;

  Map<String, int> _taskCounts = {};
  List<Map<String, dynamic>> _recentTasks = [];
  double _currentMonthHours = 0.0;

  TaskProvider(this._taskService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  Task? get currentTask => _currentTask;
  String? get error => _error;

  Map<String, int> get taskCounts => _taskCounts;
  List<Map<String, dynamic>> get recentTasks => _recentTasks;
  double get currentMonthHours => _currentMonthHours;

  // Clear any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch tasks for specific staff member
  Future<void> fetchStaffTasks(String staffId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _taskService.fetchStaffTasks(staffId);
    } catch (e) {
      _error = 'Error fetching staff tasks: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update task status
  Future<bool> updateTaskStatus(
    String taskId,
    String status,
    String staffId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _taskService.updateTaskStatus(taskId, status);
      if (success) {
        // Refresh the tasks list to get updated data
        await fetchStaffTasks(staffId);
        return true;
      } else {
        _error = 'Failed to update task status';
        return false;
      }
    } catch (e) {
      _error = 'Error updating task status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get task by ID
  Future<Task> getTaskById(String taskId) async {
    _isLoading = true;
    _currentTask = null;
    _error = null;
    notifyListeners();

    try {
      _currentTask = await _taskService.getTaskById(taskId);
      return _currentTask!;
    } catch (e) {
      _error = 'Error loading task: ${e.toString()}';
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<Task> getTasksByStatus(String status, String taskId) async {
  //   _isLoading = true;
  //   _error = null;
  //   _currentTask = null;
  //   notifyListeners();

  //   try {
  //     _currentTask = await _taskService.fetchTasksByStatus(status, taskId);
  //     if (_currentTask == null) {
  //       throw Exception('Task not found for status: $status and id: $taskId');
  //     }
  //     return _currentTask!;
  //   } catch (e) {
  //     _error = 'Error loading task: ${e.toString()}';
  //     throw Exception(_error);
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Update task with media
  Future<bool> updateTaskWithMedia({
    required String taskId,
    required String status,
    required String notes,
    required List<File> newImages,
    required List<File> newVideos,
    required String staffId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _taskService.updateTaskWithMedia(
        taskId: taskId,
        status: status,
        notes: notes,
        newImages: newImages,
        newVideos: newVideos,
      );

      if (success) {
        // Refresh current task and tasks list
        await getTaskById(taskId);
        await fetchStaffTasks(staffId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter tasks by status
  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Filter tasks by priority
  List<Task> getTasksByPriority(String priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Search tasks by title or description
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowercaseQuery = query.toLowerCase();
    return _tasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(lowercaseQuery) ||
              task.description.toLowerCase().contains(lowercaseQuery) ||
              (task.propertyName?.toLowerCase().contains(lowercaseQuery) ??
                  false),
        )
        .toList();
  }

  Future<void> _loadTaskCounts() async {
    _taskCounts = await _taskService.getCurrentMonthTaskCounts();
    notifyListeners();
  }

  Future<void> _loadRecentTasks() async {
    _recentTasks = await _taskService.getRecentTasks();
    notifyListeners();
  }

  Future<void> _loadCurrentMonthHours() async {
    _currentMonthHours = await _taskService.getCurrentMonthHours();
    notifyListeners();
  }

  Future<void> loadAllData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadTaskCounts(),
        _loadRecentTasks(),
        _loadCurrentMonthHours(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
