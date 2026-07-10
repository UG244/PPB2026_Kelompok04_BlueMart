import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/notification_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/app_theme.dart';
import 'user/user_home_screen.dart';
import 'user/user_catalog_screen.dart';
import 'user/user_favorite_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const UserCatalogScreen(),
    const UserFavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initProviders();
  }

  void _initProviders() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    if (user != null && mounted) {
      context.read<NotificationProvider>().loadSampleNotifications(
        user.username,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: AppTheme.floatingShadow,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              elevation: 0,
              backgroundColor: Colors.transparent,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view),
                  label: 'Katalog',
                ),
                BottomNavigationBarItem(
                  icon: Consumer<FavoriteProvider>(
                    builder: (_, fav, __) => Badge(
                      isLabelVisible: fav.favoriteCount > 0,
                      label: Text('${fav.favoriteCount}'),
                      child: const Icon(Icons.favorite_outline),
                    ),
                  ),
                  activeIcon: Consumer<FavoriteProvider>(
                    builder: (_, fav, __) => Badge(
                      isLabelVisible: fav.favoriteCount > 0,
                      label: Text('${fav.favoriteCount}'),
                      child: const Icon(Icons.favorite),
                    ),
                  ),
                  label: 'Favorit',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
