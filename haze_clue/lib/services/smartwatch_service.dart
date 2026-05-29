import 'dart:convert';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SmartwatchService {
  final Health health = Health();
  final String backendUrl = 'http://localhost:5000/api/v1/smartwatch/sync';

  Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    ];
    
    // Request basic permissions
    await Permission.activityRecognition.request();
    await Permission.location.request();

    bool hasPermissions = await health.hasPermissions(types) ?? false;
    if (!hasPermissions) {
      try {
        hasPermissions = await health.requestAuthorization(types);
      } catch (e) {
        print("Exception in requestAuthorization: $e");
      }
    }
    return hasPermissions;
  }

  Future<void> fetchAndSyncData() async {
    bool hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      print("No permissions to fetch health data.");
      return;
    }

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    ];

    try {
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startTime: yesterday, endTime: now, types: types);
      
      int steps = 0;
      double heartRate = 0;
      double hrv = 0;
      double sleepHours = 0;
      
      int hrCount = 0;
      int hrvCount = 0;

      for (var data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          steps += (data.value as num).toInt();
        } else if (data.type == HealthDataType.HEART_RATE) {
          heartRate += (data.value as num).toDouble();
          hrCount++;
        } else if (data.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN) {
          hrv += (data.value as num).toDouble();
          hrvCount++;
        } else if (data.type == HealthDataType.SLEEP_IN_BED) {
          // Simplistic sleep calculation for demo purposes
          sleepHours += data.dateTo.difference(data.dateFrom).inMinutes / 60.0;
        }
      }

      if (hrCount > 0) heartRate /= hrCount;
      if (hrvCount > 0) hrv /= hrvCount;

      // Sync to backend
      await _syncToBackend(steps, heartRate, hrv, sleepHours);
      
    } catch (e) {
      print("Error fetching health data: $e");
    }
  }

  Future<void> _syncToBackend(int steps, double heartRate, double hrv, double sleepScore) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Assuming JWT token is stored like this

    if (token == null) {
      print("User not authenticated, cannot sync smartwatch data.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'steps': steps,
          'heartRate': heartRate,
          'hrv': hrv,
          'sleepScore': sleepScore,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print("Smartwatch data synced successfully.");
      } else {
        print("Failed to sync smartwatch data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error syncing smartwatch data: $e");
    }
  }
}
