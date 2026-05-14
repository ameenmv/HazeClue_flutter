import 'package:flutter/material.dart';
import 'main.dart';
import 'dashboard_screen.dart';
import 'insights_screen.dart';
import 'training_screen.dart';
import 'profile_screen.dart';
import 'sessions_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  // This list links your buttons to the actual screens
  final List<Widget> _pages = [
    const DashboardContent(), // Your original Dashboard UI
    const InsightsScreen(), // The Insights page
    const TrainingScreen(), // The Training page
    const SessionsScreen(), // The Sessions page
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Insights",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: "Training",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Sessions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
