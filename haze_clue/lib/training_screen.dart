import 'package:flutter/material.dart';
import 'main.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

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
          ),
          _trainingItem(
            "Memory Training",
            "Improve recall and retention",
            Icons.extension,
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
          _buildTDCSSettings(),
          const SizedBox(height: 100), // Padding for bottom nav
        ],
      ),
    );
  }

  Widget _trainingItem(String title, String sub, IconData icon) {
    return Container(
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
          CircleAvatar(
            backgroundColor: kPrimaryPurple,
            child: const Icon(Icons.play_arrow, color: Colors.white),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Intensity Level",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "50%",
                style: TextStyle(
                  color: kPrimaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: 0.5,
            onChanged: (v) {},
            activeColor: kPrimaryPurple,
            inactiveColor: kPrimaryPurple.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
