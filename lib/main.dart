import 'package:cleanswitch_staff/navigation/bottom_bar.dart';
import 'package:cleanswitch_staff/providers/clock_in_out_provider.dart';
import 'package:cleanswitch_staff/screens/login_screen.dart';
import 'package:cleanswitch_staff/services/api_service.dart';
import 'package:cleanswitch_staff/services/clock_in_out_service.dart';
import 'package:cleanswitch_staff/services/location_service.dart';
import 'package:cleanswitch_staff/services/task_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/location_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/constant/app_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<TaskService>(
          create: (context) => TaskService(context.read<ApiService>()),
        ),
        Provider<ClockInOutService>(
          create: (context) => ClockInOutService(context.read<ApiService>()),
        ),
        // ChangeNotifierProviders - FIXED: Use factory pattern
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<LocationProvider>(
          create: (context) => LocationProvider(context.read<LocationService>()),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(context.read<TaskService>()),
        ),
        ChangeNotifierProvider<ClockInOutProvider>(
          create: (context) => ClockInOutProvider(
            locationService: context.read<ClockInOutService>(),
          ),
        ),
      ],

      child: MaterialApp(
        title: 'Staff tasks manager App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: AuthWrapper(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => const BottomBar(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Loading screen
    if (authProvider.isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF4A8EA0), AppColor.appBannerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- APP NAME ---
                const Text(
                  'CleanSwitch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cleaning Management System',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),
                // Elegant animated progress indicator
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Authentication verification...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please wait a moment.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Animated transition between authenticated and unauthenticated states
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: authProvider.isAuthenticated ? const BottomBar() : LoginScreen(),
    );
  }
}
