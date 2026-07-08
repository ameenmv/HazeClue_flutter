import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'intro_screen.dart';
import 'change_password_screen.dart';
import '../widgets/glass_widgets.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  List<dynamic> _sessions = [];
  List<dynamic> _securityLogs = [];
  bool _isLoadingSessions = true;
  bool _isLoadingLogs = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadSessions();
    _loadSecurityLogs();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final data = await ApiService.getActiveSessions();
      if (mounted) setState(() => _sessions = data);
    } catch (e) {
      debugPrint("Failed to load sessions: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _loadSecurityLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final data = await ApiService.getSecurityLogs();
      if (mounted) setState(() => _securityLogs = data);
    } catch (e) {
      debugPrint("Failed to load security logs: $e");
    } finally {
      if (mounted) setState(() => _isLoadingLogs = false);
    }
  }

  Future<void> _revokeSession(String id) async {
    try {
      await ApiService.revokeSession(id);
      _loadSessions(); // Refresh list
      if (mounted) {
        showGlassToast(context, "Session revoked successfully", isError: false);
      }
    } catch (e) {
      if (mounted) showGlassToast(context, e.toString());
    }
  }

  Future<void> _revokeOtherSessions() async {
    try {
      await ApiService.revokeOtherSessions();
      _loadSessions(); // Refresh list
      if (mounted) {
        showGlassToast(
          context,
          "Other sessions revoked successfully",
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) showGlassToast(context, e.toString());
    }
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
          "Account Security",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Account Management ---
                _buildSectionTitle("Account Management", textColor),
                const SizedBox(height: 12),
                GlassCard(
                  child: ListTile(
                    title: Text(
                      "Change password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor.withOpacity(0.5),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Active Sessions ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Active Sessions", textColor),
                    GestureDetector(
                      onTap: _revokeOtherSessions,
                      child: const Text(
                        "Sign out of all other devices",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _isLoadingSessions
                    ? Center(child: CircularProgressIndicator(color: textColor))
                    : _sessions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No active sessions found.",
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                      )
                    : GlassCard(
                        child: Column(
                          children: _sessions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final session = entry.value;
                            final isCurrent = session['isCurrent'] == true;

                            return Column(
                              children: [
                                _buildSessionItem(
                                  id: session['id'],
                                  deviceName:
                                      session['deviceName'] +
                                      (isCurrent ? " (Current)" : ""),
                                  location:
                                      session['location'] ?? "Unknown Location",
                                  time:
                                      "Started: ${DateTime.parse(session['loginTime']).toLocal().toString().split('.')[0]}",
                                  isCurrent: isCurrent,
                                  textColor: textColor,
                                ),
                                if (index < _sessions.length - 1)
                                  Divider(
                                    color: Colors.white.withOpacity(0.1),
                                    height: 1,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 32),

                // --- Recent Security Activity ---
                _buildSectionTitle("Recent Security Activity", textColor),
                const SizedBox(height: 12),
                _isLoadingLogs
                    ? Center(child: CircularProgressIndicator(color: textColor))
                    : _securityLogs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No recent security activity.",
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                      )
                    : GlassCard(
                        child: Column(
                          children: _securityLogs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final log = entry.value;
                            final event = log['event'].toString();
                            final icon =
                                event.toLowerCase().contains("password")
                                ? Icons.shield_outlined
                                : Icons.info_outline;

                            return Column(
                              children: [
                                _buildActivityItem(
                                  icon: icon,
                                  title: event,
                                  time: DateTime.parse(
                                    log['createdAt'],
                                  ).toLocal().toString().split('.')[0],
                                  textColor: textColor,
                                ),
                                if (index < _securityLogs.length - 1)
                                  Divider(
                                    color: textColor.withOpacity(0.1),
                                    height: 1,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 32),

                // --- Security Tip ---
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF8B5CF6),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Security Tip",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Regularly review your active sessions and sign out of any unfamiliar devices.",
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Log Out Button ---
                GlassButton(
                  text: "Log Out",
                  isOutlined: true,
                  onPressed: () async {
                    await ApiService.logout();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const IntroScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildSessionItem({
    required String id,
    required String deviceName,
    required String location,
    required String time,
    required bool isCurrent,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            GestureDetector(
              onTap: () => _revokeSession(id),
              child: const Text(
                "Sign out",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: textColor),
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
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
