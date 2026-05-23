import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';
import '../widgets/glass_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;

  // State variables for switches
  bool _generalNotification = true;
  bool _sound = false;
  bool _vibrate = true;

  bool _appUpdates = false;
  bool _otherUpdates = true; // For the empty label in the design

  bool _newServiceAvailable = false;
  bool _newTipsAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ApiService.getNotificationSettings();
      if (mounted) {
        setState(() {
          _generalNotification = settings['generalNotification'] ?? true;
          _sound = settings['sound'] ?? false;
          _vibrate = settings['vibrate'] ?? true;
          _appUpdates = settings['appUpdates'] ?? false;
          _otherUpdates = settings['serviceAlerts'] ?? true;
          _newServiceAvailable = settings['newServiceAvailable'] ?? false;
          _newTipsAvailable = settings['newTipsAvailable'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to load settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    // Optimistic update
    setState(() {
      switch (key) {
        case 'generalNotification': _generalNotification = value; break;
        case 'sound': _sound = value; break;
        case 'vibrate': _vibrate = value; break;
        case 'appUpdates': _appUpdates = value; break;
        case 'serviceAlerts': _otherUpdates = value; break;
        case 'newServiceAvailable': _newServiceAvailable = value; break;
        case 'newTipsAvailable': _newTipsAvailable = value; break;
      }
    });

    try {
      await ApiService.updateNotificationSettings({
        'generalNotification': _generalNotification,
        'sound': _sound,
        'vibrate': _vibrate,
        'appUpdates': _appUpdates,
        'serviceAlerts': _otherUpdates,
        'newServiceAvailable': _newServiceAvailable,
        'newTipsAvailable': _newTipsAvailable,
      });
    } catch (e) {
      debugPrint("Failed to update settings: $e");
      // Revert on failure
      setState(() {
        switch (key) {
          case 'generalNotification': _generalNotification = !value; break;
          case 'sound': _sound = !value; break;
          case 'vibrate': _vibrate = !value; break;
          case 'appUpdates': _appUpdates = !value; break;
          case 'serviceAlerts': _otherUpdates = !value; break;
          case 'newServiceAvailable': _newServiceAvailable = !value; break;
          case 'newTipsAvailable': _newTipsAvailable = !value; break;
        }
      });
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
          "Notifications",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: textColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Common Section ---
                      Text(
                        "Common",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                title: "General Notification",
                                value: _generalNotification,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('generalNotification', val),
                              ),
                              _buildDivider(textColor),
                              _buildSwitchTile(
                                title: "Sound",
                                value: _sound,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('sound', val),
                              ),
                              _buildDivider(textColor),
                              _buildSwitchTile(
                                title: "Vibrate",
                                value: _vibrate,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('vibrate', val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- System & services update Section ---
                      Text(
                        "System & services update",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                title: "App updates",
                                value: _appUpdates,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('appUpdates', val),
                              ),
                              _buildDivider(textColor),
                              _buildSwitchTile(
                                title: "Service alerts",
                                value: _otherUpdates,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('serviceAlerts', val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Others Section ---
                      Text(
                        "Others",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildSwitchTile(
                                title: "New Service Available",
                                value: _newServiceAvailable,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('newServiceAvailable', val),
                              ),
                              _buildDivider(textColor),
                              _buildSwitchTile(
                                title: "New Tips Available",
                                value: _newTipsAvailable,
                                textColor: textColor,
                                onChanged: (val) => _updateSetting('newTipsAvailable', val),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF8B5CF6),
            thumbColor: textColor,
            trackColor: textColor.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color textColor) {
    return Divider(
      height: 24,
      thickness: 1,
      color: textColor.withOpacity(0.1),
    );
  }
}
