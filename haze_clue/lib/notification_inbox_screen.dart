import 'package:flutter/material.dart';
import 'api_service.dart';
import 'glass_widgets.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = ApiService.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiService.markAllNotificationsRead();
              setState(() {
                _notificationsFuture = ApiService.getNotifications();
              });
            },
            child: const Text("Mark All Read", style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: FutureBuilder<List<dynamic>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: textColor));
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 60, color: textColor.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text("No notifications found.", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16)),
                    ],
                  ),
                );
              }

              final notifications = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        if (notif['isRead'] == false) {
                          await ApiService.markNotificationRead(notif['id']);
                          setState(() {
                            _notificationsFuture = ApiService.getNotifications();
                          });
                        }
                      },
                      child: _buildNotificationItem(
                        context: context,
                        icon: Icons.notifications,
                        title: notif['title'] ?? 'Notification',
                        message: notif['message'] ?? '...',
                        time: "Recently", 
                        isNew: notif['isRead'] == false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isNew,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isNew ? const Color(0xFF8B5CF6) : textColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isNew ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
              child: Icon(icon, color: isNew ? Colors.white : textColor.withOpacity(0.7), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isNew ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                      if (isNew) ...[
                        Text(
                          " • ",
                          style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.5)),
                        ),
                        const Text(
                          "New",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
