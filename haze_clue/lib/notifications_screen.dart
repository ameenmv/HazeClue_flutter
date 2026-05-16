import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'api_service.dart';
import 'glass_widgets.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Common Section ---
                      const Text(
                        "Common",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                                onChanged: (val) => _updateSetting('generalNotification', val),
                              ),
                              _buildDivider(),
                              _buildSwitchTile(
                                title: "Sound",
                                value: _sound,
                                onChanged: (val) => _updateSetting('sound', val),
                              ),
                              _buildDivider(),
                              _buildSwitchTile(
                                title: "Vibrate",
                                value: _vibrate,
                                onChanged: (val) => _updateSetting('vibrate', val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- System & services update Section ---
                      const Text(
                        "System & services update",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                                onChanged: (val) => _updateSetting('appUpdates', val),
                              ),
                              _buildDivider(),
                              _buildSwitchTile(
                                title: "Service alerts",
                                value: _otherUpdates,
                                onChanged: (val) => _updateSetting('serviceAlerts', val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Others Section ---
                      const Text(
                        "Others",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                                onChanged: (val) => _updateSetting('newServiceAvailable', val),
                              ),
                              _buildDivider(),
                              _buildSwitchTile(
                                title: "New Tips Available",
                                value: _newTipsAvailable,
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF8B5CF6),
            thumbColor: Colors.white,
            trackColor: Colors.white.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 24,
      thickness: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}
