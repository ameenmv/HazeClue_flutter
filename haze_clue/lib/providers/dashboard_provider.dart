import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class DeviceConnectionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
  
  void setConnected(bool value) {
    state = value;
  }
}

// Provide device connection state
final isDeviceConnectedProvider = NotifierProvider<DeviceConnectionNotifier, bool>(() {
  return DeviceConnectionNotifier();
});

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
