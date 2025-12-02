import 'package:cleanswitch_staff/screens/clock_in_out.dart';
import 'package:cleanswitch_staff/screens/home_screen.dart';
import 'package:cleanswitch_staff/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  final _pageController = PageController();

  // Screens for each tab
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClockInOutScreen(),
    const ProfileScreen(),
  ];

  // Navigation items data
  final List<BottomNavigationItem> _navItems = const [
    BottomNavigationItem(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    BottomNavigationItem(
      label: 'Clock In/Out',
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer_rounded,
    ),
    BottomNavigationItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColor.appBannerColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle:
              TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontSize: 12.sp),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: _navItems.map((item) => _buildBottomNavItem(item)).toList(),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(BottomNavigationItem item) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Icon(item.icon),
      ),
      activeIcon: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Icon(item.activeIcon),
      ),
      label: item.label,
      tooltip: item.label, // Accessibility
    );
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

// Helper class for navigation items
class BottomNavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const BottomNavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
