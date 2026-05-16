import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'insights_screen.dart';
import 'training_screen.dart';
import 'profile_screen.dart';
import 'sessions_screen.dart';
import 'glass_widgets.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const InsightsScreen(),
    const TrainingScreen(),
    const SessionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Very important for the background to show through!
        extendBody: true, // This allows the body to extend behind the bottom nav bar
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isLight ? Colors.white.withOpacity(0.6) : const Color(0xFF1E1E2A).withOpacity(0.6), // Dynamic translucent
                border: Border(
                  top: BorderSide(
                    color: textColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: BottomNavigationBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: const Color(0xFF8B5CF6),
                    unselectedItemColor: textColor.withOpacity(0.5),
                    showUnselectedLabels: true,
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    items: [
                      _buildNavItem(Icons.home_rounded, "Home", 0),
                      _buildNavItem(Icons.bar_chart_rounded, "Insights", 1),
                      _buildNavItem(Icons.psychology, "Training", 2),
                      _buildNavItem(Icons.assignment_rounded, "Sessions", 3),
                      _buildNavItem(Icons.person_outline_rounded, "Profile", 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
