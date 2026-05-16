import 'package:flutter/material.dart';
import 'main.dart';
import 'my_devices_screen.dart';
import 'concentration_puzzle_screen.dart';
import 'notification_inbox_screen.dart';
import 'api_service.dart';
import 'training_screen.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<dynamic>> _sessionsFuture;
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getDashboardStats();
    _sessionsFuture = ApiService.getSessions();
    _notificationsFuture = ApiService.getNotifications();
  }

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
          FutureBuilder<List<dynamic>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.where((n) => n['isRead'] == false).length;
              }

              Widget icon = const Icon(
                Icons.notifications_none_outlined,
                color: kTextDark,
                size: 28,
              );

              if (unreadCount > 0) {
                icon = Stack(
                  clipBehavior: Clip.none,
                  children: [
                    icon,
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '+9' : unreadCount.toString(),
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
              }

              return IconButton(
                icon: icon,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationInboxScreen(),
                    ),
                  );
                  // Refresh notifications count when returning from inbox
                  setState(() {
                    _notificationsFuture = ApiService.getNotifications();
                  });
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _statsFuture = ApiService.getDashboardStats();
            _sessionsFuture = ApiService.getSessions();
            _notificationsFuture = ApiService.getNotifications();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      height: 250,
                      child: Center(child: Text("Failed to load stats", textAlign: TextAlign.center,)),
                    );
                  }
                  
                  final stats = snapshot.data ?? {};
                  final focusPercentage = (stats['avgAttention'] ?? 100) / 100.0;
                  final focusLabel = '${(focusPercentage * 100).toInt()}%';

                  return _buildFocusCard(focusPercentage, focusLabel);
                },
              ),
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
              FutureBuilder<List<dynamic>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Failed to load activities"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No recent activities."));
                  }
                  return _buildActivityList(snapshot.data!);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusCard(double focusPercentage, String focusLabel) {
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
                  value: focusPercentage, 
                  strokeWidth: 14,
                  backgroundColor: Colors.grey.shade100,
                  color: kPrimaryPurple,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    focusLabel,
                    style: const TextStyle(
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
              MaterialPageRoute(builder: (_) => const TrainingScreen()),
            );
          },
        ),
        _actionItem(
          Icons.music_note_outlined,
          "Binaural\nBeats",
          const Color(0xFFF0FFF4),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrainingScreen()),
            );
          },
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

  Widget _buildActivityList(List<dynamic> sessions) {
    return Column(
      children: sessions.take(3).map((session) {
        return _activityTile(
          Icons.trending_up, 
          session['title'] ?? 'Session Completed',
          session['status'] ?? 'Recently',
        );
      }).toList(),
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
