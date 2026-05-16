import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SignalRService {
  HubConnection? _hubConnection;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final serverUrl = '${ApiService.baseUrl.replaceAll('/api/v1', '')}/sessionHub';

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: HttpConnectionOptions(
          accessTokenFactory: () async => token ?? '',
        ))
        .build();

    _hubConnection?.onclose(({error}) {
      debugPrint("SignalR Connection Closed: $error");
    });

    try {
      await _hubConnection?.start();
      debugPrint("SignalR Connected Successfully");
    } catch (e) {
      debugPrint("SignalR Connection Error: $e");
    }
  }

  Future<void> streamConcentrationData(String sessionId, int concentration) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection?.invoke("StreamConcentrationData", args: [sessionId, concentration]);
      } catch (e) {
        debugPrint("Error streaming data: $e");
      }
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection?.stop();
    }
  }
}
