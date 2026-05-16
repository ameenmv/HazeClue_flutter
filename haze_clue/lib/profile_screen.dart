import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'notification_inbox_screen.dart';
import 'help_support_screen.dart';
import 'contact_us_screen.dart';
import 'account_security_screen.dart';
import 'privacy_policy_screen.dart';
import 'intro_screen.dart';
import 'glass_widgets.dart';
import 'utils/transitions.dart';

import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();
      setState(() {
        _profile = profile;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let AnimatedBackground show through
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // --- Top App Bar Icons ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          GlassPageRoute(
                            page: const NotificationInboxScreen(),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.history, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Profile Content ---
            Column(
              children: [
                const SizedBox(height: 80),

                // --- Avatar ---
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 55,
                        backgroundImage: AssetImage('assets/images/Intro.png'), // Placeholder
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // Edit Icon
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          GlassPageRoute(
                            page: const EditProfileScreen(),
                          ),
                        );
                        _loadProfile(); // Refresh profile after editing
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E1E2A), width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- User Info ---
                Text(
                  _profile?['fullName'] ?? "Loading...",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _profile?['email'] ?? "loading@example.com",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // --- Menu Groups ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Group 1
                      _buildMenuGroup([
                        _buildMenuItem(
                          icon: Icons.badge_outlined,
                          title: "Edit profile information",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              GlassPageRoute(
                                page: const EditProfileScreen(),
                              ),
                            );
                            _loadProfile(); // Refresh profile after editing
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.notifications_none,
                          title: "Notifications",
                          trailingText: "ON",
                          onTap: () {
                            Navigator.push(
                              context,
                              GlassPageRoute(
                                page: const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.language,
                          title: "Language",
                          trailingText: "English",
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Group 2
                      _buildMenuGroup([
                        _buildMenuItem(
                          icon: Icons.security_outlined,
                          title: "Security",
                          onTap: () {
                            Navigator.push(
                              context,
                              GlassPageRoute(
                                page: const AccountSecurityScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.palette_outlined,
                          title: "Theme",
                          trailingText: "Dark glass",
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Group 3
                      _buildMenuGroup([
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: "Help & Support",
                          onTap: () {
                            Navigator.push(
                              context,
                              GlassPageRoute(
                                page: const HelpSupportScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.chat_bubble_outline,
                          title: "Contact us",
                          onTap: () {
                            Navigator.push(
                              context,
                              GlassPageRoute(
                                page: const ContactUsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: "Privacy policy",
                          onTap: () {
                            Navigator.push(
                              context,
                              GlassPageRoute(
                                page: const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                      ]),
                      const SizedBox(height: 32),
                      
                      // --- Logout Button ---
                      GlassButton(
                        text: "Logout",
                        isOutlined: true,
                        onPressed: () async {
                          await ApiService.logout();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            GlassPageRoute(page: const IntroScreen()),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return GlassCard(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30), // Match GlassCard
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
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
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
