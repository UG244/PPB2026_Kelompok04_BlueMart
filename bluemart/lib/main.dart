import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/notification_helper.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'providers/favorite_provider.dart';
import 'providers/notification_provider.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_product_list_screen.dart';
import 'screens/admin/admin_product_form_screen.dart';
import 'screens/admin/admin_sales_report_screen.dart';
import 'screens/user/user_cart_screen.dart';
import 'screens/user/user_checkout_screen.dart';
import 'screens/user/user_order_history_screen.dart';
import 'screens/user/barcode_scanner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const BlueMartApp(),
    ),
  );
}

class BlueMartApp extends StatelessWidget {
  const BlueMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueMart',
      navigatorKey: NotificationHelper.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/main':
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(),
            );
          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            );
          case '/barcode-scanner':
            return MaterialPageRoute(
              builder: (_) => const BarcodeScannerScreen(),
            );
          case '/admin-dashboard':
            return MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen(),
            );
          case '/admin-products':
            return MaterialPageRoute(
              builder: (_) => const AdminProductListScreen(),
            );
          case '/admin-product-form':
            return MaterialPageRoute(
              builder: (_) => const AdminProductFormScreen(),
            );
          case '/admin-sales-report':
            return MaterialPageRoute(
              builder: (_) => const AdminSalesReportScreen(),
            );
          case '/user-cart':
            return MaterialPageRoute(builder: (_) => const UserCartScreen());
          case '/user-checkout':
            return MaterialPageRoute(
              builder: (_) => const UserCheckoutScreen(),
            );
          case '/user-orders':
            return MaterialPageRoute(
              builder: (_) => const UserOrderHistoryScreen(),
            );
          case '/map':
            return MaterialPageRoute(builder: (_) => const MapScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Halaman tidak ditemukan')),
              ),
            );
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    _timer = Timer(const Duration(milliseconds: 1500), () async {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!mounted) return;

      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (!mounted) return;
        if (user != null) {
          if (user.role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.store, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'BlueMart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Belanja Hemat & Cepat',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
