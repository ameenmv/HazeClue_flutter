import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart'; // For colors
import 'api_service.dart';
import 'intro_screen.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Account Security",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Account Management ---
            _buildSectionTitle("Account Management"),
            const SizedBox(height: 12),
            _buildContainer(
              child: ListTile(
                title: const Text(
                  "Change password",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextDark),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {
                  // Navigate to change password
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),

            // --- Authentication ---
            _buildSectionTitle("Authentication"),
            const SizedBox(height: 12),
            _buildContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Two-factor authentication",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Set up two-factor authentication",
                            style: TextStyle(
                              fontSize: 13,
                              color: kPrimaryPurple.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: _isTwoFactorEnabled,
                      activeColor: kPrimaryPurple,
                      onChanged: (val) {
                        setState(() {
                          _isTwoFactorEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Active Sessions ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Active Sessions"),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Sign out of all other devices",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryPurple.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContainer(
              child: Column(
                children: [
                  _buildSessionItem(
                    deviceName: "iPhone 13 Mini (Current)",
                    location: "New York, USA",
                    time: "Last active: Just now",
                  ),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  _buildSessionItem(
                    deviceName: "MacBook Air M2",
                    location: "London, UK",
                    time: "Last active: 2 days ago",
                  ),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  _buildSessionItem(
                    deviceName: "Samsung Galaxy S23",
                    location: "Berlin, Germany",
                    time: "Last active: 1 week ago",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Recent Security Activity ---
            _buildSectionTitle("Recent Security Activity"),
            const SizedBox(height: 12),
            _buildContainer(
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.shield_outlined,
                    title: "Password changed successfully",
                    time: "2 hours ago",
                  ),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  _buildActivityItem(
                    icon: Icons.error_outline,
                    title: "New device login from unrecognised location",
                    time: "Yesterday",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Security Tip ---
            _buildContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: kPrimaryPurple.withOpacity(0.8), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "Security Tip",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Regularly review your active sessions and sign out of any unfamiliar devices.",
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextLightGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Log Out Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await ApiService.logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const IntroScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336), // Red color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kTextDark,
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildSessionItem({
    required String deviceName,
    required String location,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextLightGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextLightGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              "Sign out",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kPrimaryPurple.withOpacity(0.9),
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
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: kTextDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextLightGrey,
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
