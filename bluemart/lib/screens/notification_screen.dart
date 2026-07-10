import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../utils/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeTab = ['all', 'order', 'promo'][_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: const Text('Tandai Dibaca'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Pesanan'),
                Tab(text: 'Promo'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                final notifications = provider.getByType(_activeTab);
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada notifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _NotificationCard(
                        notification: notif,
                        onTap: () => provider.markAsRead(notif.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  IconData get _icon {
    switch (notification.type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'order':
        return AppTheme.primaryDark;
      case 'promo':
        return AppTheme.accentOrange;
      default:
        return AppTheme.accent;
    }
  }

  Color get _bgColor {
    switch (notification.type) {
      case 'order':
        return AppTheme.primaryDark.withValues(alpha: 0.1);
      case 'promo':
        return AppTheme.accentOrange.withValues(alpha: 0.1);
      default:
        return AppTheme.accent.withValues(alpha: 0.1);
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return DateFormat('dd/MM/yyyy').format(notification.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo,
                      style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
