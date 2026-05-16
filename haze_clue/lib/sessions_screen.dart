import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart'; // For colors
import 'api_service.dart';
import 'device_data_service.dart';
import 'signalr_service.dart';
import 'my_devices_screen.dart';

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

  bool _isCheckingDevice = false;

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to check devices')));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start session')));
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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save session')));
      }
    }
  }

  void _showCompletionDialog(int avgConcentration, int elapsedSeconds) {
    String timeString = _formatTime(elapsedSeconds);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Session Complete!"),
        content: Text("You completed $timeString of focus.\n\nAverage Concentration: $avgConcentration%"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("Done", style: TextStyle(color: kPrimaryPurple)),
          ),
        ],
      ),
    );
  }

  void _showDeviceRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Device Required"),
        content: const Text("You need to connect an EEG headset or smartwatch to start a focus session. Do you want to connect a device now?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyDevicesScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryPurple),
            child: const Text("Connect Device", style: TextStyle(color: Colors.white)),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Concentration level",
          style: TextStyle(
            color: Colors.black,
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
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // --- Ongoing Timer Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _isSessionActive ? _formatTime(_secondsRemaining) : _formatTime(_selectedDuration * 60),
                      style: const TextStyle(
                        fontSize: 48, // Made larger
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "From $_selectedDuration minutes",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Custom Linear Progress Bar for Time
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _isSessionActive 
                          ? 1.0 - (_secondsRemaining / (_selectedDuration * 60)) 
                          : 0.0,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryPurple),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Session Configuration Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Session Configuration",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Colors.black87),
                      const SizedBox(width: 8),
                      const Text(
                        "Duration(min)",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? kPrimaryPurple : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$duration",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : kTextDark,
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
                  const SizedBox(height: 32),
                  
                  // Live Concentration Rate Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Live Concentration Rate",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _isSessionActive ? "$_currentConcentration%" : "--%",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: LinearProgressIndicator(
                        value: _isSessionActive ? _currentConcentration / 100 : 0.0,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isSessionActive || _isCheckingDevice) ? _endSession : _startSession,
                          icon: _isCheckingDevice
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(
                                  _isSessionActive ? Icons.stop : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: Text(
                            _isCheckingDevice 
                                ? "Checking Device..." 
                                : (_isSessionActive ? "End Session" : "Start Session"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSessionActive ? const Color(0xFFE53935) : kPrimaryPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      if (_isSessionActive) const SizedBox(width: 16),
                      if (_isSessionActive)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pauseOrResumeSession,
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              color: kTextDark,
                              size: 18,
                            ),
                            label: Text(
                              _isPaused ? "Resume" : "Pause",
                              style: const TextStyle(
                                color: kTextDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
