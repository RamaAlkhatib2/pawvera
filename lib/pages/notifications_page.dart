import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Vaccination Reminder',
      description: 'Max is due for rabies vaccination tomorrow',
      timeAgo: '2 hours ago',
      icon: Icons.access_time,
      iconColor: const Color(0xFF6B9BD1),
      backgroundColor: const Color(0xFFF0F5FB),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Upcoming Appointment',
      description: 'Grooming appointment for Bella at 3:00 PM today',
      timeAgo: '4 hours ago',
      icon: Icons.calendar_today,
      iconColor: const Color(0xFFD4A574),
      backgroundColor: const Color(0xFFFBF7F0),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Order Shipped',
      description: 'Your order of Premium Dog Food is on the way',
      timeAgo: '1 day ago',
      icon: Icons.local_shipping,
      iconColor: const Color(0xFF6BB88C),
      backgroundColor: const Color(0xFFF0FBF5),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'New Adoption Listing',
      description: 'A Golden Retriever puppy is available for adoption near you',
      timeAgo: '1 day ago',
      icon: Icons.favorite,
      iconColor: const Color(0xFFD97F8A),
      backgroundColor: const Color(0xFFFBF0F3),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Walking Time',
      description: 'Time for Charlie\'s evening walk',
      timeAgo: '2 days ago',
      icon: Icons.access_time,
      iconColor: const Color(0xFF6B9BD1),
      backgroundColor: const Color(0xFFF0F5FB),
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Appointment Confirmed',
      description: 'Your appointment has been confirmed',
      timeAgo: '3 days ago',
      icon: Icons.calendar_today,
      iconColor: const Color(0xFFD4A574),
      backgroundColor: const Color(0xFFFBF7F0),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$unreadCount new',
                style: const TextStyle(
                  color: Color(0xFF3AA78E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: Color(0xFF3AA78E),
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Select',
                    style: TextStyle(
                      color: Color(0xFF3AA78E),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(notifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        // Mark as read when tapped
        setState(() {
          final index = notifications.indexOf(notification);
          notifications[index] = notification.copyWith(isRead: true);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : notification.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead
              ? Border.all(color: Colors.grey.shade200)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3AA78E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.grey.shade600,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isRead: isRead ?? this.isRead,
    );
  }
}
