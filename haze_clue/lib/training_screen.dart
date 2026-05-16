import 'package:flutter/material.dart';
import 'api_service.dart';
import 'concentration_puzzle_screen.dart';
import 'memory_training_screen.dart';
import 'glass_widgets.dart';
import 'utils/transitions.dart';

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
        showGlassToast(context, "Failed to save settings: $e");
      }
    }
  }

  void _toggleAudio(String title) {
    setState(() {
      if (_currentlyPlaying == title) {
        _currentlyPlaying = null; // Pause
      } else {
        _currentlyPlaying = title; // Play
        showGlassToast(context, "Now playing: $title...", isError: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background transparent to let AnimatedBackground show
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Training & Setting",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Cognitive Training Modules",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _trainingItem(
            "Focus Enhancement",
            "Exercises designed to sharpen focus",
            Icons.center_focus_strong,
            onTap: () {
              Navigator.push(
                context,
                GlassPageRoute(page: const ConcentrationPuzzleScreen()),
              );
            },
          ),
          _trainingItem(
            "Memory Training",
            "Improve recall and retention",
            Icons.extension,
            onTap: () {
              Navigator.push(
                context,
                GlassPageRoute(page: const MemoryTrainingScreen()),
              );
            },
          ),

          const SizedBox(height: 40),
          const Text(
            "Binaural Beats Presets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

          const SizedBox(height: 40),
          const Text(
            "tDCS Settings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF8B5CF6), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _audioPresetCard(String title, String time, String desc) {
    bool isPlaying = _currentlyPlaying == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleAudio(title),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isPlaying ? Colors.redAccent : const Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPlaying ? Colors.redAccent : const Color(0xFF8B5CF6)).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTDCSSettings() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Intensity Level",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                ),
                Text(
                  "${(_intensityLevel * 100).toInt()}%",
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF8B5CF6),
                inactiveTrackColor: Colors.white.withOpacity(0.1),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                trackHeight: 6.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              ),
              child: Slider(
                value: _intensityLevel,
                onChanged: _updateIntensity,
                onChangeEnd: _saveIntensity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
