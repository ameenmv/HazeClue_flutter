import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart';
import 'shared_widgets.dart';

class TdcsConsentScreen extends StatefulWidget {
  const TdcsConsentScreen({super.key});

  @override
  State<TdcsConsentScreen> createState() => _TdcsConsentScreenState();
}

class _TdcsConsentScreenState extends State<TdcsConsentScreen> {
  // Checklist states
  final List<bool> _checklist = List.generate(5, (_) => false);

  // Final consent switches
  bool _consentDataUsage = false;
  bool _consentActivateTdcs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "tDCS Consent",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Intro Section ---
            const Text(
              "Understanding Transcranial Direct Current Stimulation (tDCS)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildParagraph(
                "tDCS is a non-invasive brain stimulation method that uses a low-level, constant electrical current to stimulate specific brain areas."),
            _buildParagraph(
                "When used with HazeClue, tDCS aims to enhance cognitive functions such as focus, attention, and learning, helping you achieve peak mental performance in your gamified challenges. The effects are typically subtle and cumulative."),
            _buildParagraph(
                "It is important to use tDCS responsibly and according to guidelines. Your safety is our top priority."),
            const SizedBox(height: 32),

            // --- Checklist Section ---
            const Text(
              "Essential Safety Checklist",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            _buildParagraph(
                "Before activating tDCS, please confirm the following to ensure safe and effective use."),
            const SizedBox(height: 16),

            _buildChecklistItem(
              index: 0,
              title: "I have consulted a medical professional",
              subtitle:
                  "Ensure tDCS is suitable for your individual health conditions.",
            ),
            _buildChecklistItem(
              index: 1,
              title:
                  "I have no metallic implants or electronic devices in my head/body",
              subtitle: "Such devices can interfere with tDCS, posing safety risks.",
            ),
            _buildChecklistItem(
              index: 2,
              title:
                  "My scalp/skin is healthy and free from cuts, lesions, or irritation",
              subtitle:
                  "Healthy skin is crucial for proper electrode contact and safety.",
            ),
            _buildChecklistItem(
              index: 3,
              title: "I am not pregnant or breastfeeding",
              subtitle:
                  "tDCS safety during pregnancy/breastfeeding is not established.",
            ),
            _buildChecklistItem(
              index: 4,
              title: "I understand the potential risks and side effects",
              subtitle:
                  "Familiarize yourself with possible mild sensations or rare adverse effects.",
            ),
            const SizedBox(height: 32),

            // --- Presets Section ---
            const Text(
              "tDCS Intensity Presets",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            _buildParagraph(
                "Choose an intensity level based on your comfort and desired cognitive boost."),
            const SizedBox(height: 16),

            _buildPresetCard(
              icon: Icons.flash_on, // Mocking the icon
              title: "Low Focus",
              subtitle: "Gentle stimulation for mild cognitive enhancement and relaxation.",
            ),
            _buildPresetCard(
              icon: Icons.psychology, // Mocking the icon
              title: "Medium Concentration",
              subtitle: "Balanced current for enhanced attention and sustained focus.",
            ),
            _buildPresetCard(
              icon: Icons.favorite_border, // Mocking the icon
              title: "High Peak Performance",
              subtitle:
                  "More intensive stimulation for maximum cognitive demand activities.",
            ),
            const SizedBox(height: 32),

            // --- Final Consent Section ---
            const Text(
              "Final Consent",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            _buildParagraph(
                "Your explicit consent is required to activate tDCS features within HazeClue."),
            const SizedBox(height: 16),

            _buildSwitchItem(
              title: "Consent to Data Usage for Personalization",
              value: _consentDataUsage,
              onChanged: (val) => setState(() => _consentDataUsage = val),
            ),
            _buildSwitchItem(
              title: "Consent to Activate tDCS Feature",
              value: _consentActivateTdcs,
              onChanged: (val) => setState(() => _consentActivateTdcs = val),
            ),
            const SizedBox(height: 32),

            // --- Buttons ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Handle Activation
                },
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text(
                  "Activate tDCS & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Handle Opt Out
                },
                icon: const Icon(Icons.person_off_outlined, color: Colors.redAccent),
                label: const Text(
                  "Opt Out Completely",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: kTextLightGrey,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _checklist[index],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _checklist[index] = val);
                }
              },
              activeColor: kPrimaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: Colors.grey, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          // Shield Icon
          const Icon(
            Icons.verified_user_outlined,
            color: kPrimaryPurple,
            size: 20,
          ),
          const SizedBox(width: 8),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: kTextLightGrey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: kPrimaryPurple, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextLightGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextDark,
                fontSize: 14,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: kPrimaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
