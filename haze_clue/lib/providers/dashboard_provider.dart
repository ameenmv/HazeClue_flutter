import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Provide the stats
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ApiService.getDashboardStats();
});

// Provide the sessions
final recentSessionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ApiService.getSessions();
});

// Provide the notifications
final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ApiService.getNotifications();
});

// Provide the unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (data) => data.where((n) => n['isRead'] == false).length,
    orElse: () => 0,
  );
});
