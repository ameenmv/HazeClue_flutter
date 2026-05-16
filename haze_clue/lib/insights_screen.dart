import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';
import 'glass_widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  int _totalFocusSeconds = 0;
  int _averageMinutesPerDay = 0;
  int _overallAverageConcentration = 0;
  int _totalSessionsCount = 0;
  int _improvementPercentage = 0;
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
        _totalFocusSeconds = data['totalFocusSeconds'] ?? 0;
        _averageMinutesPerDay = data['averageMinutesPerDay'] ?? 0;
        _overallAverageConcentration = data['overallAverageConcentration'] ?? 0;
        _totalSessionsCount = data['totalSessionsCount'] ?? 0;
        _improvementPercentage = data['improvementPercentage'] ?? 0;
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

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds secs';
    }
    int totalMinutes = totalSeconds ~/ 60;
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
      backgroundColor: Colors.transparent, // Let AnimatedBackground show through
      appBar: AppBar(
        title: const Text(
          "Insights",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (_totalFocusSeconds == 0) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroStats(),
          const SizedBox(height: 32),
          const Text(
            "Weekly Focus Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthlyGraph(),
          const SizedBox(height: 100), // padding for bottom nav
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.insert_chart_outlined, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Sessions Yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Start your first session to see your insights and track your progress over time!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7), height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.timer, "Total Time", _formatDuration(_totalFocusSeconds))),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(Icons.psychology, "Avg Conc.", "$_overallAverageConcentration%")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.calendar_month, "Sessions", "$_totalSessionsCount")),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _improvementPercentage >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: _improvementPercentage >= 0 ? Colors.greenAccent : Colors.redAccent,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Trend",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_improvementPercentage >= 0 ? '+' : ''}$_improvementPercentage%",
                        style: TextStyle(
                          color: _improvementPercentage >= 0 ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF8B5CF6), size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatDuration(_totalFocusSeconds),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${_formatDuration(_averageMinutesPerDay * 60)} Avg per Day", 
              style: TextStyle(color: Colors.white.withOpacity(0.6))
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Line Chart for Weekly Data
        GlassCard(
          child: Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 24, right: 24, left: 12, bottom: 12),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
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
                            child: Text(days[value.toInt()], style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
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
                        return Text('${value.toInt()}m', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10));
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
                    color: const Color(0xFF8B5CF6),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyGraph() {
    return GlassCard(
      child: Container(
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 24, right: 24, left: 12, bottom: 12),
        child: BarChart(
          BarChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
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
                        child: Text(months[value.toInt()], style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
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
                    return Text('${value.toInt()}m', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10));
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
                    color: const Color(0xFF8B5CF6),
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
