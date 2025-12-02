import 'package:cleanswitch_staff/providers/auth_provider.dart';
import 'package:cleanswitch_staff/widgets/common/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cleanswitch_staff/widgets/common/custom_app_bar.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/constant/app_color.dart';
import '../widgets/common/string_utils.dart';
import 'package:cleanswitch_staff/screens/task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  String? _staffId;
  bool _initialized = false;

  final List<String> _statuses = ['All', 'pending', 'in_progress', 'completed'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final id = authProvider.userId;
    if (id != null) {
      setState(() => _staffId = id);
      await Provider.of<TaskProvider>(
        context,
        listen: false,
      ).fetchStaffTasks(id);
    }
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    List<Task> filteredTasks = _selectedStatus == 'All'
        ? taskProvider.tasks
        : taskProvider.getTasksByStatus(_selectedStatus);

    if (_searchQuery.isNotEmpty) {
      filteredTasks = taskProvider.searchTasks(_searchQuery);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'My Tasks'),
      body: !_initialized
          ? const ModernLoader(text: "Fetching tasks...")
          : taskProvider.isLoading
              ? const ModernLoader(text: "Fetching tasks...")
              : RefreshIndicator(
                  onRefresh: () async {
                    if (_staffId != null) {
                      await taskProvider.fetchStaffTasks(_staffId!);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🧭 Status filter chips
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _statuses.map((status) {
                              final isSelected = _selectedStatus == status;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(StringUtils.capitalize(status).replaceAll('_', ' '),),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedStatus = status;
                                    });
                                  },
                                  selectedColor: AppColor.appBannerColor,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🧩 Task list
                        Expanded(
                          child: filteredTasks.isEmpty
                              ? Center(
                                  child: Text(
                                    'No tasks found.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = filteredTasks[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black12.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: _getStatusColor(
                                            task.status,
                                          ).withOpacity(0.15),
                                          radius: 22,
                                          child: Icon(
                                            _getStatusIcon(task.status),
                                            color: _getStatusColor(task.status),
                                          ),
                                        ),
                                        title: Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            task.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        trailing: Chip(
                                          backgroundColor: _getStatusColor(
                                            task.status,
                                          ).withOpacity(0.1),
                                          label: Text(
                                            StringUtils.capitalize(task.status).replaceAll('_', ' '),
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                  task.status),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TaskDetailScreen(
                                                taskId: task.id.toString(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.autorenew;
      case 'pending':
        return Icons.hourglass_bottom;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}