import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'api_service.dart';
import 'concentration_puzzle_screen.dart';
import 'main.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  double _intensityLevel = 0.5;
  bool _isLoading = true;
  String? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _loadDeviceSettings();
  }

  Future<void> _loadDeviceSettings() async {
    try {
      final settings = await ApiService.getDeviceSettings();
      if (mounted) {
        setState(() {
          _intensityLevel = (settings['intensityLevel'] as num?)?.toDouble() ?? 0.5;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to load device settings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateIntensity(double value) {
    setState(() => _intensityLevel = value);
  }

  Future<void> _saveIntensity(double value) async {
    try {
      await ApiService.updateDeviceSettings(value);
    } catch (e) {
      debugPrint("Failed to save intensity: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save settings: $e")),
        );
      }
    }
  }

  void _toggleAudio(String title) {
    setState(() {
      if (_currentlyPlaying == title) {
        _currentlyPlaying = null; // Pause
      } else {
        _currentlyPlaying = title; // Play
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.music_note, color: Colors.white),
                const SizedBox(width: 8),
                Text("Now playing: $title..."),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: kPrimaryPurple,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Training & Setting",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        // Naturally scrollable
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Cognitive Training Modules",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _trainingItem(
            "Focus Enhancement",
            "Exercises designed to sharpen focus",
            Icons.center_focus_strong,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConcentrationPuzzleScreen()),
              );
            },
          ),
          _trainingItem(
            "Memory Training",
            "Improve recall and retention",
            Icons.extension,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Memory Training coming soon!")),
              );
            },
          ),

          const SizedBox(height: 32),
          const Text(
            "Binaural Beats Presets",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _audioPresetCard(
            "Alpha Wave Relaxation",
            "30 min",
            "Ideal for stress relief",
          ),
          _audioPresetCard(
            "Theta Wave Meditation",
            "45 min",
            "Enhances creative thinking",
          ),

          const SizedBox(height: 32),
          const Text(
            "tDCS Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTDCSSettings(),
          const SizedBox(height: 100), // Padding for bottom nav
        ],
      ),
    );
  }

  Widget _trainingItem(String title, String sub, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  sub,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      ),
    );
  }

  Widget _audioPresetCard(String title, String time, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryPurple,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _toggleAudio(title),
            child: CircleAvatar(
              backgroundColor: _currentlyPlaying == title ? Colors.redAccent : kPrimaryPurple,
              child: Icon(
                _currentlyPlaying == title ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTDCSSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Intensity Level",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "${(_intensityLevel * 100).toInt()}%",
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _intensityLevel,
            onChanged: _updateIntensity,
            onChangeEnd: _saveIntensity,
            activeColor: kPrimaryPurple,
            inactiveColor: kPrimaryPurple.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
