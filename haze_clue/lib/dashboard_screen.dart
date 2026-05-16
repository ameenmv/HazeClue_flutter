import 'package:flutter/material.dart';
import 'my_devices_screen.dart';
import 'concentration_puzzle_screen.dart';
import 'notification_inbox_screen.dart';
import 'api_service.dart';
import 'training_screen.dart';
import 'glass_widgets.dart';
import 'utils/transitions.dart';

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
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _statsFuture = ApiService.getDashboardStats();
      _sessionsFuture = ApiService.getSessions();
      _notificationsFuture = ApiService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background transparent to let AnimatedBackground show
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLight ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: textColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "HazeClue",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 20,
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

              Widget icon = Icon(
                Icons.notifications_none_outlined,
                color: textColor,
                size: 28,
              );

              if (unreadCount > 0) {
                icon = Stack(
                  clipBehavior: Clip.none,
                  children: [
                    icon,
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5),
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
                    GlassPageRoute(
                      page: const NotificationInboxScreen(),
                    ),
                  );
                  _refreshData();
                },
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await Future.wait([_statsFuture, _sessionsFuture, _notificationsFuture]);
        },
        backgroundColor: const Color(0xFF1E1E2A),
        color: const Color(0xFF8B5CF6),
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
                    return SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator(color: textColor)),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      height: 250,
                      child: Center(child: Text("Failed to load stats", style: TextStyle(color: textColor))),
                    );
                  }
                  
                  final stats = snapshot.data ?? {};
                  final focusPercentage = (stats['avgAttention'] ?? 100) / 100.0;
                  final focusLabel = '${(focusPercentage * 100).toInt()}%';

                  return _buildFocusCard(focusPercentage, focusLabel, textColor);
                },
              ),
              const SizedBox(height: 40),
              
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context, textColor),
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Icon(Icons.trending_up, color: textColor.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FutureBuilder<List<dynamic>>(
                    future: _sessionsFuture,
                    builder: (context, snapshot) {
                      final textColor = Theme.of(context).colorScheme.onSurface;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: textColor));
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Failed to load activities", style: TextStyle(color: textColor)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text("No recent activities.", style: TextStyle(color: textColor.withOpacity(0.7))),
                          ),
                        );
                      }
                      return _buildActivityList(snapshot.data!, textColor);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 100), // Padding for the bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusCard(double focusPercentage, String focusLabel, Color textColor) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.more_horiz, color: textColor.withOpacity(0.5)),
            ),
            Text(
              "Current Focus",
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.7),
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
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      focusLabel,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      "Focused",
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
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
                color: textColor.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(
          Icons.bolt,
          "Connect\nDevices",
          textColor,
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(page: const MyDevicesScreen()),
            );
          },
        ),
        _actionItem(
          Icons.psychology_outlined,
          "Training\nExercises",
          textColor,
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(page: const TrainingScreen()),
            );
          },
        ),
        _actionItem(
          Icons.music_note_outlined,
          "Binaural\nBeats",
          textColor,
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(page: const TrainingScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, Color textColor, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            GlassCard(
              child: SizedBox(
                height: 70,
                width: 70,
                child: Center(
                  child: Icon(icon, color: textColor, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(List<dynamic> sessions, Color textColor) {
    return Column(
      children: sessions.take(3).map((session) {
        return _activityTile(
          Icons.trending_up, 
          session['title'] ?? 'Session Completed',
          session['status'] ?? 'Recently',
          textColor,
        );
      }).toList(),
    );
  }

  Widget _activityTile(IconData icon, String title, String time, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
