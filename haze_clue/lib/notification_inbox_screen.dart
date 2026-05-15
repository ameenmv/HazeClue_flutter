import 'package:flutter/material.dart';
import 'main.dart'; // For colors
import 'api_service.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          final notifications = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return GestureDetector(
                onTap: () async {
                  if (notif['isRead'] == false) {
                    await ApiService.markNotificationRead(notif['id']);
                    setState(() {
                      _notificationsFuture = ApiService.getNotifications();
                    });
                  }
                },
                child: _buildNotificationItem(
                  icon: Icons.notifications,
                  iconColor: kPrimaryPurple,
                  title: notif['title'] ?? 'Notification',
                  message: notif['message'] ?? '...',
                  time: "Recently", 
                  isNew: notif['isRead'] == false,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    Color? iconBackgroundColor,
    required String title,
    required String message,
    required String time,
    required bool isNew,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: iconBackgroundColor != null
              ? const EdgeInsets.all(8)
              : EdgeInsets.zero,
          decoration: iconBackgroundColor != null
              ? BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                )
              : null,
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextLightGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      color: kTextLightGrey,
                    ),
                  ),
                  if (isNew) ...[
                    const Text(
                      " — ",
                      style: TextStyle(fontSize: 13, color: kTextLightGrey),
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
    );
  }
}
