import 'package:flutter/material.dart';
import 'main.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Insights",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Focus Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyStatsCard(),
            const SizedBox(height: 32),
            const Text(
              "Months Focus Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildMonthlyGraph(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Total Focus Duration",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Text(
              "4:32",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryPurple,
              ),
            ),
            const SizedBox(width: 8),
            Text("Avg per Day", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 20),
        // Placeholder for the line chart
        SizedBox(
          height: 150,
          width: double.infinity,
          child: Image.asset(
            'assets/weekly_graph.png',
          ), // Use fl_chart here in a real app
        ),
      ],
    );
  }

  Widget _buildMonthlyGraph() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset('assets/monthly_grid_graph.png'),
    );
  }
}
