import 'package:flutter/material.dart';
import 'main.dart';
import 'my_devices_screen.dart';
import 'concentration_puzzle_screen.dart';
import 'notification_inbox_screen.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: kPrimaryPurple,
                size: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: kTextDark,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationInboxScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFocusCard(),
            const SizedBox(height: 32),
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                Icon(Icons.trending_up, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.more_horiz, color: Colors.grey),
          ),
          const Text(
            "Current Focus",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: 0.8, // Adjust based on data
                  strokeWidth: 14,
                  backgroundColor: Colors.grey.shade100,
                  color: kPrimaryPurple,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  const Text(
                    "100%",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  Text(
                    "Focused",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Your cognitive state is optimal.\nKeep it up!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Use this for the 3-column action row
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(
          Icons.bolt,
          "Connect\nDevices",
          const Color(0xFFF0EFFF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyDevicesScreen()),
            );
          },
        ),
        _actionItem(
          Icons.psychology_outlined,
          "Training\nExercises",
          const Color(0xFFFFF0F0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ConcentrationPuzzleScreen()),
            );
          },
        ),
        _actionItem(
          Icons.music_note_outlined,
          "Binaural\nBeats",
          const Color(0xFFF0FFF4),
        ),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, Color bgColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: kPrimaryPurple, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        _activityTile(
          Icons.trending_up,
          "30 min Focus Session completed",
          "1 hour ago",
        ),
        _activityTile(
          Icons.psychology_outlined,
          "Cognitive Training: Memory Drill",
          "Yesterday",
        ),
        _activityTile(
          Icons.music_note_outlined,
          "Listened to Alpha Waves for 45 min",
          "2 days ago",
        ),
      ],
    );
  }

  // This is the helper for the individual rows inside the list
  Widget _activityTile(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimaryPurple, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
