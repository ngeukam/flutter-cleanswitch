import 'dart:io';
import 'package:cleanswitch_staff/widgets/common/modern_loader.dart';
import 'package:cleanswitch_staff/widgets/common/string_utils.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';
import 'package:cleanswitch_staff/widgets/task_details/copyabletext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/app_button.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/auth_service.dart';
import '../widgets/task_details/task_image_grid.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _loading = true;
  String? _staffId;
  Task? _task;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedStatus;
  List<File> _newImages = [];
  List<File> _newVideos = [];

  SnackBar _buildSuccessSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.green,
    );
  }

  SnackBar _buildErrorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.red,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTask();
  }

  Future<void> _initializeTask() async {
    final id = await AuthService().getUserId();
    if (id != null) {
      _staffId = id;
      final provider = Provider.of<TaskProvider>(context, listen: false);
      final task = await provider.getTaskById(widget.taskId);
      setState(() {
        _task = task;
        _notesController.text = task.notes ?? '';
        _selectedStatus = task.status;
        _loading = false;
      });
    }
  }

  void _handleDeleteNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _handleDeleteExistingImage(int index) {
    // Handle deletion of existing images if needed
    // This might require API call to delete from server
    print('Delete existing image at index: $index');
  }

  void _handleNewVideoAdded(File videoFile) {
    setState(() {
      _newVideos.add(videoFile);
    });
  }

  void _handleDeleteNewVideo(int index) {
    setState(() {
      _newVideos.removeAt(index);
    });
  }

  Future<void> _updateTask() async {
    if (_staffId == null || _task == null || _selectedStatus == null) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);
    final success = await provider.updateTaskWithMedia(
      taskId: _task!.id.toString(),
      status: _selectedStatus!,
      notes: _notesController.text,
      newImages: _newImages,
      newVideos: _newVideos,
      staffId: _staffId!,
    );
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildSuccessSnackBar('Task updated successfully'));

      // Refresh the task data after successful update
      final updatedTask = await provider.getTaskById(widget.taskId);
      setState(() {
        _task = updatedTask;
        // Clear new media after successful upload
        _newImages.clear();
        _newVideos.clear();
      });
    } else if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildErrorSnackBar(provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Task Details'),
      body: _loading || provider.isLoading
          ? const ModernLoader(text: "Loading task...")
          : _task == null
          ? const Center(child: Text('Task not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width -
                      32, // Largeur écran - padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      _task!.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Description copiable
                    const SizedBox(height: 8),
                    const Text(
                      "Description:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CopyableText(
                      text: _task!.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    // Dans la section Status, remplacez le Row actuel par :
                    Row(
                      children: [
                        const Text(
                          "Status: ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          // <-- Ajoutez Expanded ici
                          child: DropdownButton<String>(
                            isExpanded:
                                true, // <-- Important pour que le dropdown prenne toute la largeur
                            value: _selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                            items: ['pending', 'in_progress', 'completed']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(
                                      StringUtils.capitalize(
                                        status,
                                      ).replaceAll('_', ' '),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Priority Chip
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        const Text(
                          "Priority: ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Chip(
                          label: Text(
                            _task!.priority.toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getPriorityColor(_task!.priority),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Due Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: AppColor.appBannerColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _task!.formattedDueDate,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Property
                    if (_task!.propertyName != null)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Icon(
                            Icons.home_work,
                            size: 20,
                            color: AppColor.appBannerColor,
                          ),
                          const Text(
                            "Property:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _task!.propertyName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Apartments assigned
                    if (_task!.apartmentsAssigned != null &&
                        _task!.apartmentsAssigned!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              const Text(
                                "Apartments Assigned:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  "${_task!.apartmentsAssigned!.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _task!.apartmentsAssigned!
                                  .map(
                                    (apt) => Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Chip(
                                        label: Text(
                                          apt.displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.teal,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    // Notes field
                    const Text(
                      "Notes:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add notes about this task...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Media Section
                    const Text(
                      "Media",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TaskImageGrid(
                      task: _task,
                      newImages: _newImages,
                      newVideos: _newVideos,
                      onDeleteNewImage: _handleDeleteNewImage,
                      onDeleteExistingImage: _handleDeleteExistingImage,
                      onNewVideoAdded: _handleNewVideoAdded,
                      onDeleteNewVideo: _handleDeleteNewVideo,
                    ),
                    const SizedBox(height: 24),

                    // Update button
                    AppButton(
                      buttonText: 'Update Task',
                      onPressed: _updateTask,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
