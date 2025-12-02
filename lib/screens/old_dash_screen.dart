import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cleanswitch_staff/screens/tasks_list_screen.dart';
import 'package:cleanswitch_staff/widgets/task_dashboard/location_widget.dart';
import 'package:cleanswitch_staff/widgets/task_dashboard/monthly_hours_card.dart';
import 'package:cleanswitch_staff/widgets/task_dashboard/recent_activity_list.dart';
import 'package:cleanswitch_staff/widgets/task_dashboard/task_status_grid.dart';
import 'package:cleanswitch_staff/screens/task_details_screen.dart';
import 'package:cleanswitch_staff/providers/task_provider.dart';
import 'package:cleanswitch_staff/providers/location_provider.dart';
import 'package:cleanswitch_staff/providers/auth_provider.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';
import 'package:cleanswitch_staff/widgets/common/string_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  double _animatedHours = 0;
  bool _initialDataLoaded = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Wait for the first frame to be rendered before accessing providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoadingData) return;
    
    setState(() {
      _isLoadingData = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();
      final locationProvider = context.read<LocationProvider>();

      await Future.wait([
        taskProvider.loadAllData(),
        locationProvider.getCurrentLocation(),
      ]);
      
      // Animate progress after data is loaded
      _animateProgress(taskProvider.currentMonthHours / 180.0);
    } catch (e) {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _initialDataLoaded = true;
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isLoadingData) return;
    
    setState(() {
      _isLoadingData = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();
      final locationProvider = context.read<LocationProvider>();

      await Future.wait([
        taskProvider.loadAllData(),
        locationProvider.getCurrentLocation(),
      ]);
      
      // Re-animate progress with new data
      _animateProgress(taskProvider.currentMonthHours / 180.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _animateProgress(double targetValue) {
    final animation = Tween(begin: 0.0, end: targetValue).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ),
    );
    
    animation.addListener(() {
      if (mounted) {
        setState(() => _animatedHours = animation.value);
      }
    });
    
    _progressController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      flexibleSpace: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.appBannerColor.withOpacity(0.8),
                    AppColor.appBannerColor.withOpacity(0.2),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      StringUtils.capitalize(authProvider.fullName ?? 'Staff Member'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<LocationProvider>(
                      builder: (context, locationProvider, child) {
                        return LocationWidget(
                          userLocation: locationProvider.currentLocation ?? "Loading location...",
                          isLoading: locationProvider.isLoading,
                          onRefresh: () => locationProvider.getCurrentLocation(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverList _buildContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              // Show loading skeleton while initial data is loading
              if (!_initialDataLoaded) {
                return _buildSkeletonLoading();
              }

              // Show error if task data loading failed and no data exists
              if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
                return _buildErrorWidget(taskProvider.error!);
              }

              // Show main content
              return Column(
                children: [
                  MonthlyHoursCard(
                    currentHours: taskProvider.currentMonthHours,
                    animatedHours: _animatedHours * 180.0,
                  ),
                  const SizedBox(height: 20),
                  TaskStatusGrid(taskCounts: taskProvider.taskCounts),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(taskProvider),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildRecentActivitySection(TaskProvider taskProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.appFont,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TaskListScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColor.appBannerColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RecentActivityList(
          recentTasks: taskProvider.recentTasks,
          onTaskTap: (taskId) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(
                  taskId: taskId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        _buildSkeletonCard(height: 150),
        const SizedBox(height: 20),
        _buildSkeletonCard(height: 200),
        const SizedBox(height: 20),
        _buildSkeletonCard(height: 250),
      ],
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.appFont,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.appBannerColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}