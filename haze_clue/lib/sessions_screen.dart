import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';
import 'device_data_service.dart';
import 'signalr_service.dart';
import 'my_devices_screen.dart';
import 'glass_widgets.dart';
import 'utils/transitions.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  int _selectedDuration = 15;
  final List<int> _durations = [5, 10, 15, 20, 25, 30];
  
  bool _isSessionActive = false;
  bool _isPaused = false;
  String? _sessionId;

  // Timer state
  Timer? _countdownTimer;
  int _secondsRemaining = 15 * 60;
  
  // Data streaming state
  final DeviceDataService _deviceDataService = DeviceDataService();
  final SignalRService _signalRService = SignalRService();
  
  int _currentConcentration = 0;
  int _totalConcentrationSum = 0;
  int _concentrationDataPoints = 0;
  StreamSubscription<int>? _streamSubscription;

  bool _isCheckingDevice = false;

  @override
  void initState() {
    super.initState();
    _signalRService.connect();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _streamSubscription?.cancel();
    _deviceDataService.dispose();
    _signalRService.disconnect();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_isSessionActive || _isCheckingDevice) return;

    setState(() {
      _isCheckingDevice = true;
    });

    try {
      final devices = await ApiService.getDevices();
      if (devices.isEmpty) {
        setState(() {
          _isCheckingDevice = false;
        });
        _showDeviceRequiredDialog();
        return;
      }
    } catch (e) {
      debugPrint('Error checking devices: $e');
      setState(() {
        _isCheckingDevice = false;
      });
      if (mounted) showGlassToast(context, 'Failed to check devices');
      return;
    }

    setState(() {
      _isCheckingDevice = false;
      _isSessionActive = true;
      _secondsRemaining = _selectedDuration * 60;
      _totalConcentrationSum = 0;
      _concentrationDataPoints = 0;
      _isPaused = false;
    });

    try {
      final res = await ApiService.createSession("Focus Session", _selectedDuration, null);
      _sessionId = res['id'];
      
      _startTimerAndStream();
    } catch (e) {
      debugPrint('Failed to start session: $e');
      setState(() => _isSessionActive = false);
      if (mounted) showGlassToast(context, 'Failed to start session');
    }
  }

  void _startTimerAndStream() {
    _deviceDataService.startStreaming();
    _streamSubscription = _deviceDataService.concentrationStream.listen((value) {
      if (!_isPaused) {
        setState(() {
          _currentConcentration = value;
          _totalConcentrationSum += value;
          _concentrationDataPoints++;
        });
        
        if (_sessionId != null) {
          _signalRService.streamConcentrationData(_sessionId!, value);
        }
      }
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _endSession();
          }
        });
      }
    });
  }

  Future<void> _pauseOrResumeSession() async {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_sessionId != null) {
      try {
        if (_isPaused) {
          await ApiService.pauseSession(_sessionId!);
        } else {
          await ApiService.resumeSession(_sessionId!);
        }
      } catch (e) {
        debugPrint('Failed to toggle pause state on server: $e');
      }
    }
  }

  Future<void> _endSession() async {
    _countdownTimer?.cancel();
    _streamSubscription?.cancel();
    _deviceDataService.stopStreaming();

    setState(() {
      _isSessionActive = false;
    });

    int averageConcentration = 0;
    if (_concentrationDataPoints > 0) {
      averageConcentration = (_totalConcentrationSum / _concentrationDataPoints).round();
    }

    int elapsedSeconds = (_selectedDuration * 60) - _secondsRemaining;

    if (_sessionId != null) {
      try {
        await ApiService.completeSession(_sessionId!, averageConcentration, elapsedSeconds);
        _showCompletionDialog(averageConcentration, elapsedSeconds);
      } catch (e) {
        debugPrint('Failed to complete session: $e');
        if (mounted) showGlassToast(context, 'Failed to save session');
      }
    }
  }

  void _showCompletionDialog(int avgConcentration, int elapsedSeconds) {
    String timeString = _formatTime(elapsedSeconds);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text("Session Complete!", style: TextStyle(color: Colors.white)),
        content: Text(
          "You completed $timeString of focus.\n\nAverage Concentration: $avgConcentration%",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done", style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeviceRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text("Device Required", style: TextStyle(color: Colors.white)),
        content: Text(
          "You need to connect an EEG headset or smartwatch to start a focus session. Do you want to connect a device now?",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                GlassPageRoute(page: const MyDevicesScreen()),
              );
            },
            child: const Text("Connect Device", style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Concentration level",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSessionActive 
                  ? (_isPaused ? "The session is paused." : "The session is ongoing.") 
                  : "Ready to focus?",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // --- Ongoing Timer Card ---
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        _isSessionActive ? _formatTime(_secondsRemaining) : _formatTime(_selectedDuration * 60),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "From $_selectedDuration minutes",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _isSessionActive 
                            ? 1.0 - (_secondsRemaining / (_selectedDuration * 60)) 
                            : 0.0,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- Session Configuration Card ---
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Session Configuration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 20, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        Text(
                          "Duration (min)",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Duration Bubbles
                    IgnorePointer(
                      ignoring: _isSessionActive,
                      child: Opacity(
                        opacity: _isSessionActive ? 0.5 : 1.0,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _durations.map((duration) {
                            bool isSelected = duration == _selectedDuration;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDuration = duration;
                                  _secondsRemaining = duration * 60;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ] : null,
                                ),
                                child: Text(
                                  "$duration",
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Live Concentration Rate Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Live Concentration Rate",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _isSessionActive ? "$_currentConcentration%" : "--%",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        child: LinearProgressIndicator(
                          value: _isSessionActive ? _currentConcentration / 100 : 0.0,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (_isSessionActive || _isCheckingDevice) ? _endSession : _startSession,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: _isSessionActive 
                                      ? [Colors.redAccent.shade400, Colors.redAccent.shade700]
                                      : const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isCheckingDevice)
                                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  else
                                    Icon(
                                      _isSessionActive ? Icons.stop : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCheckingDevice 
                                        ? "Checking..." 
                                        : (_isSessionActive ? "End Session" : "Start Session"),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_isSessionActive) const SizedBox(width: 12),
                        if (_isSessionActive)
                          Expanded(
                            child: GestureDetector(
                              onTap: _pauseOrResumeSession,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isPaused ? Icons.play_arrow : Icons.pause,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isPaused ? "Resume" : "Pause",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
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
                ),
              ),
            ),
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
    );
  }
}
