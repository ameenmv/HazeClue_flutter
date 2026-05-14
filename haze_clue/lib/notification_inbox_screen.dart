import 'package:flutter/material.dart';
import 'main.dart'; // For colors

class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            _buildNotificationItem(
              icon: Icons.bluetooth,
              iconColor: Colors.blueAccent,
              title: "Device Connection Alert",
              message:
                  "Your Bluetooth disconnected unexpectedly during your last focus session. Please check its battery.",
              time: "2 mins ago",
              isNew: true,
            ),
            const SizedBox(height: 24),
            _buildNotificationItem(
              icon: Icons.psychology,
              iconColor: kPrimaryPurple,
              title: "AI Insight: Improved Focus",
              message: "A 5-minute break will help you come back stronger.",
              time: "8 mins ago",
              isNew: true,
            ),
            const SizedBox(height: 24),
            _buildNotificationItem(
              icon: Icons.system_update_alt,
              iconColor: kPrimaryPurple,
              title: "App Update Available",
              message:
                  "Version 2.3.0 is here with new great analytics and performance improvements.",
              time: "1 hour ago",
              isNew: false,
            ),
            const SizedBox(height: 24),
            _buildNotificationItem(
              icon: Icons.adjust,
              iconColor: kPrimaryPurple,
              title: "New Focus Preset Idea",
              message:
                  "Try our new “Deep Work Flow” preset for enhanced productivity sessions.",
              time: "2 hours ago",
              isNew: false,
            ),
            const SizedBox(height: 24),
            _buildNotificationItem(
              icon: Icons.notifications,
              iconColor: kPrimaryPurple,
              iconBackgroundColor: kPrimaryPurple.withOpacity(0.1),
              title: "Session Reminder: Meditation",
              message:
                  "Your daily meditation session is scheduled for 7 PM today. Find your peace.",
              time: "Yesterday",
              isNew: false,
            ),
          ],
        ),
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
