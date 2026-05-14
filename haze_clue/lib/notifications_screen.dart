import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart'; // For colors

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // State variables for switches
  bool _generalNotification = true;
  bool _sound = false;
  bool _vibrate = true;

  bool _appUpdates = false;
  bool _otherUpdates = true; // For the empty label in the design

  bool _newServiceAvailable = false;
  bool _newTipsAvailable = true;

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
      body: SingleChildScrollView(
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
              onChanged: (val) => setState(() => _generalNotification = val),
            ),
            _buildSwitchTile(
              title: "Sound",
              value: _sound,
              onChanged: (val) => setState(() => _sound = val),
            ),
            _buildSwitchTile(
              title: "Vibrate",
              value: _vibrate,
              onChanged: (val) => setState(() => _vibrate = val),
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
              onChanged: (val) => setState(() => _appUpdates = val),
            ),
            // The design has a switch without a label, adding a placeholder label
            _buildSwitchTile(
              title: "Service alerts",
              value: _otherUpdates,
              onChanged: (val) => setState(() => _otherUpdates = val),
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
              onChanged: (val) => setState(() => _newServiceAvailable = val),
            ),
            _buildSwitchTile(
              title: "New Tips Available",
              value: _newTipsAvailable,
              onChanged: (val) => setState(() => _newTipsAvailable = val),
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
