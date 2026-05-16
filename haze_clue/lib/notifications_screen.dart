import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart'; // For colors

import 'api_service.dart';

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: "General Notification",
              value: _generalNotification,
              onChanged: (val) => _updateSetting('generalNotification', val),
            ),
            _buildSwitchTile(
              title: "Sound",
              value: _sound,
              onChanged: (val) => _updateSetting('sound', val),
            ),
            _buildSwitchTile(
              title: "Vibrate",
              value: _vibrate,
              onChanged: (val) => _updateSetting('vibrate', val),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
            ),

            // --- System & services update Section ---
            const SizedBox(height: 8),
            const Text(
              "System & services update",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: "App updates",
              value: _appUpdates,
              onChanged: (val) => _updateSetting('appUpdates', val),
            ),
            // The design has a switch without a label, adding a placeholder label
            _buildSwitchTile(
              title: "Service alerts",
              value: _otherUpdates,
              onChanged: (val) => _updateSetting('serviceAlerts', val),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
            ),

            // --- Others Section ---
            const SizedBox(height: 8),
            const Text(
              "Others",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: "New Service Available",
              value: _newServiceAvailable,
              onChanged: (val) => _updateSetting('newServiceAvailable', val),
            ),
            _buildSwitchTile(
              title: "New Tips Available",
              value: _newTipsAvailable,
              onChanged: (val) => _updateSetting('newTipsAvailable', val),
            ),
          ],
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: kTextDark,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: kPrimaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
