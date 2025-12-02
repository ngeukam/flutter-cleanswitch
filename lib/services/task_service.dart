import 'dart:convert';
import 'dart:io';
import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  Future<List<Task>> fetchStaffTasks(String staffId) async {
    final response = await _apiService.get('/tasks/?assigned_to=$staffId');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> tasksData = responseData['data']['data'];
      return tasksData.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    final response = await _apiService.patch(
      '/tasks/$taskId/update_status/',
      {'status': status},
    );
    return response.statusCode == 200;
  }

  Future<Task> getTaskById(String taskId) async {
    final response = await _apiService.get('/tasks/$taskId/');
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load task: ${response.statusCode}');
    }
  }

  Future<bool> updateTaskWithMedia({
    required String taskId,
    required String status,
    required String notes,
    required List<File> newImages,
    required List<File> newVideos,
  }) async {
    // Combine all files to upload
    final allFiles = [...newImages, ...newVideos];
    List<Map<String, dynamic>> galleryImages = [];
    print('allFiles Images to be sent: $allFiles');
    if (allFiles.isNotEmpty) {
      galleryImages = await _apiService.uploadTaskMediaFiles(allFiles);
    }
    
    final response = await _apiService.patch(
      '/tasks/$taskId/',
      {
        'status': status,
        'notes': notes,
        if (galleryImages.isNotEmpty) 'gallery_images': galleryImages,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else if (response.statusCode == 400) {
      final responseBody = json.decode(response.body);
      if (responseBody['message'] == "Completed tasks cannot be modified.") {
        throw Exception('Completed tasks cannot be modified.');
      } else {
        throw Exception('Cannot complete a pending task without progress');
      }
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  Future<Task> fetchTasksByStatus(String status, String taskId) async {
    final response = await _apiService.get('/tasks/$taskId/?status=$status');
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tasks by status: ${response.statusCode}');
    }
  }

  Future<List<Task>> fetchTasksByProperty(String propertyId) async {
    final response = await _apiService.get('/tasks/?property=$propertyId');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks by property: ${response.statusCode}');
    }
  }
  
  Future<Map<String, int>> getCurrentMonthTaskCounts() async {
    final response = await _apiService.get('/users/tasks/current-month-counts/');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'pending': data['pending'] ?? 0,
        'in_progress': data['in_progress'] ?? 0,
        'completed': data['completed'] ?? 0,
        'cancelled': data['cancelled'] ?? 0,
      };
    } else {
      throw Exception('Failed to load task counts');
    }
  }

   Future<List<Map<String, dynamic>>> getRecentTasks() async {
    final response = await _apiService.get('/users/tasks/recent/');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load recent tasks');
    }
  }

  Future<Map<String, dynamic>> getMonthlyWorkHours({
    int? month, 
    int? year,
  }) async {
    const endpoint = '/users/work-hours/monthly/';
    final response = await _apiService.get(endpoint);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load work hours: ${response.statusCode}');
    }
  }

  Future<double> getCurrentMonthHours() async {
    final data = await getMonthlyWorkHours();
    return (data['total_hours'] as num).toDouble();
  }
}