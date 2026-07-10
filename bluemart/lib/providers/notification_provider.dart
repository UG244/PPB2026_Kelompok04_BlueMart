import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  void loadSampleNotifications(String userId) {
    _notifications.clear();
    _notifications.addAll([
      NotificationModel(
        id: '1',
        userId: userId,
        title: 'Pesanan Dikirim',
        message: 'Pesanan #123 sudah dikirim dan sedang dalam perjalanan.',
        type: 'order',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        userId: userId,
        title: 'Promo Spesial!',
        message:
            'Diskon 50% Flash Sale hari ini! Buruan belanja sebelum kehabisan.',
        type: 'promo',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        userId: userId,
        title: 'Pesanan Selesai',
        message: 'Terima kasih sudah berbelanja di BlueMart!',
        type: 'order',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '4',
        userId: userId,
        title: 'Voucher Baru',
        message:
            'Dapatkan voucher gratis ongkir untuk pembelian minimal Rp 50.000',
        type: 'promo',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '5',
        userId: userId,
        title: 'Update Sistem',
        message:
            'BlueMart versi 2.0 telah hadir dengan fitur baru yang menarik!',
        type: 'system',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
    _updateUnreadCount();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
      _updateUnreadCount();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = NotificationModel(
        id: _notifications[i].id,
        userId: _notifications[i].userId,
        title: _notifications[i].title,
        message: _notifications[i].message,
        type: _notifications[i].type,
        isRead: true,
        createdAt: _notifications[i].createdAt,
      );
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  List<NotificationModel> getByType(String type) {
    if (type == 'all') return _notifications;
    return _notifications.where((n) => n.type == type).toList();
  }
}
