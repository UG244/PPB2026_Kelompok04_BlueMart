import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final double iconSize;
  final Color? iconColor;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    this.iconSize = 22,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, _) {
        return Stack(
          children: [
            IconButton(
              onPressed:
                  onTap ?? () => Navigator.pushNamed(context, '/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                size: iconSize,
                color: iconColor,
              ),
            ),
            if (notifProvider.unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${notifProvider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
