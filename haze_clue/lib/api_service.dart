import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, or localhost for Chrome/Linux desktop
  static const String baseUrl = 'http://localhost:5220/api/v1';

  // ─── Token helpers ───────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── AUTH ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/account/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'FullName': name,
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      if (data['access_token'] != null) await saveToken(data['access_token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/account/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (data['access_token'] != null) await saveToken(data['access_token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  static Future<void> logout() async {
    final headers = await _authHeaders();
    await http.post(Uri.parse('$baseUrl/account/logout'), headers: headers);
    await deleteToken();
  }


  static Future<void> requestPasswordReset(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/account/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Failed to request reset');
    }
  }

  static Future<String> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/account/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['resetToken'] ?? '';
    }
    final data = jsonDecode(res.body);
    throw Exception(data['message'] ?? 'Failed to verify OTP');
  }

  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/account/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Password reset failed');
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/account/change-password'),
      headers: headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Failed to change password');
    }
  }

  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/users/me/notification-settings'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get notification settings');
  }

  static Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    final headers = await _authHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/users/me/notification-settings'),
      headers: headers,
      body: jsonEncode(settings),
    );
    if (res.statusCode != 200) throw Exception('Failed to update notification settings');
  }

  static Future<Map<String, dynamic>> getDeviceSettings() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/users/me/device-settings'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get device settings');
  }

  static Future<void> updateDeviceSettings(double intensityLevel) async {
    final headers = await _authHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/users/me/device-settings'),
      headers: headers,
      body: jsonEncode({'intensityLevel': intensityLevel}),
    );
    if (res.statusCode != 200) throw Exception('Failed to update device settings');
  }

  static Future<List<dynamic>> getActiveSessions() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/account/sessions'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get sessions');
  }

  static Future<void> revokeSession(String id) async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse('$baseUrl/account/sessions/$id'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Failed to revoke session');
  }

  static Future<void> revokeOtherSessions() async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse('$baseUrl/account/sessions/other'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Failed to revoke other sessions');
  }

  static Future<List<dynamic>> getSecurityLogs() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/account/security-logs'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get security logs');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get profile');
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get dashboard stats');
  }

  static Future<List<dynamic>> getSessions() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/sessions'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get sessions');
  }

  static Future<Map<String, dynamic>> getInsights() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/sessions/insights'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get insights');
  }

  static Future<List<dynamic>> getNotifications() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get notifications');
  }

  static Future<void> submitHealthAssessment(Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/assessments/health'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to submit health assessment');
    }
  }

  static Future<void> submitTdcsConsent(Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/assessments/tdcs-consent'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to submit TDCS consent');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? nickname,
    String? phoneNumber,
    String? country,
    String? address,
  }) async {
    print('Sending profile update to backend with name: $fullName');
    final headers = await _authHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/users/me'),
      headers: headers,
      body: jsonEncode({
        'fullName': fullName,
        if (nickname != null) 'nickname': nickname,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (country != null) 'country': country,
        if (address != null) 'address': address,
      }),
    );
    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update profile: ${res.body}');
  }



  static Future<List<dynamic>> getDevices() async {
    final headers = await _authHeaders();
    final res = await http.get(Uri.parse('$baseUrl/devices'), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get devices');
  }

  static Future<Map<String, dynamic>> addDevice(String name, String macAddress) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/devices'),
      headers: headers,
      body: jsonEncode({'name': name, 'macAddress': macAddress}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    final error = jsonDecode(res.body);
    throw Exception(error['message'] ?? 'Failed to add device');
  }

  static Future<void> deleteDevice(String id) async {
    final headers = await _authHeaders();
    final res = await http.delete(Uri.parse('$baseUrl/devices/$id'), headers: headers);
    if (res.statusCode != 200) throw Exception('Failed to delete device');
  }

  static Future<Map<String, dynamic>> createSession(String title, int durationMinutes, String? deviceId) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'durationMinutes': durationMinutes,
        'deviceId': deviceId
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to create session');
  }

  static Future<void> completeSession(String id) async {
    final headers = await _authHeaders();
    final res = await http.post(Uri.parse('$baseUrl/sessions/$id/complete'), headers: headers);
    if (res.statusCode != 200) throw Exception('Failed to complete session');
  }

  static Future<void> submitSessionScore(String id, int score, int timeSeconds) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/sessions/$id/score'),
      headers: headers,
      body: jsonEncode({'score': score, 'completionTimeSeconds': timeSeconds}),
    );
    if (res.statusCode != 200) throw Exception('Failed to submit score');
  }

  static Future<void> markNotificationRead(String id) async {
    final headers = await _authHeaders();
    await http.patch(Uri.parse('$baseUrl/notifications/$id/read'), headers: headers);
  }

  static Future<void> markAllNotificationsRead() async {
    final headers = await _authHeaders();
    await http.patch(Uri.parse('$baseUrl/notifications/read-all'), headers: headers);
  }

  static Future<void> submitSupportTicket(String subject, String message) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/support/ticket'),
      headers: headers,
      body: jsonEncode({'subject': subject, 'message': message}),
    );
    if (res.statusCode != 200) throw Exception('Failed to submit ticket');
  }
}
