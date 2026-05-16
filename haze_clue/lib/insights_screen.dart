import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';
import 'main.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  int _totalFocusMinutes = 0;
  int _averageMinutesPerDay = 0;
  List<int> _weeklyData = [];
  List<int> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final data = await ApiService.getInsights();
      if (!mounted) return;
      setState(() {
        _totalFocusMinutes = data['totalFocusMinutes'] ?? 0;
        _averageMinutesPerDay = data['averageMinutesPerDay'] ?? 0;
        _weeklyData = List<int>.from(data['weeklyData'] ?? []);
        _monthlyData = List<int>.from(data['monthlyData'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')} hrs';
    }
    return '$minutes mins';
  }

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryPurple));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_totalFocusMinutes == 0) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text(
              "No Focus Sessions Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Start your first session to see your insights and track your progress over time!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: kTextLightGrey),
            ),
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
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatDuration(_totalFocusMinutes),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kPrimaryPurple,
              ),
            ),
            const SizedBox(width: 8),
            Text("${_formatDuration(_averageMinutesPerDay)} Avg per Day", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 20),
        
        // Line Chart for Weekly Data
        Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 24, right: 16, left: 0, bottom: 0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const days = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 30, // assuming 30 min intervals
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}m', style: const TextStyle(color: Colors.grey, fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(_weeklyData.length, (index) {
                    return FlSpot(index.toDouble(), _weeklyData[index].toDouble());
                  }),
                  isCurved: true,
                  color: kPrimaryPurple,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: kPrimaryPurple.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyGraph() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, right: 16, left: 0, bottom: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['-5m', '-4m', '-3m', '-2m', 'Last m', 'This m'];
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(months[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 60,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}m', style: const TextStyle(color: Colors.grey, fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_monthlyData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _monthlyData[index].toDouble(),
                  color: kPrimaryPurple,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
