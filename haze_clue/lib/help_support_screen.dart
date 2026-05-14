import 'package:flutter/material.dart';
import 'main.dart'; // For colors

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
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
          "Help & Support",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                filled: true,
                fillColor: const Color(0xFFF5F5F5), // Light gray
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),

            // Expansion Tiles
            _buildFAQCategory(
              title: "General Queries",
              count: "3",
              initiallyExpanded: true,
              children: [
                _buildFAQItem(
                  question: "How do I get started with the EEG App?",
                  answer:
                      "Download the app from your respective app store, create an account, and follow the on-screen setup instructions to pair your device.",
                ),
                _buildFAQItem(
                  question: "What devices are compatible with the app?",
                  answer:
                      "The EEG App is compatible with all major iOS and Android smartphones and tablets running version 12.0 or higher for iOS, and 8.0 or higher for Android. Specific hardware models are listed in the app's settings.",
                ),
                _buildFAQItem(
                  question: "Is my data secure?",
                  answer:
                      "Yes, we use industry-standard encryption and security protocols to protect your personal and health data. For more details, please refer to our privacy policy.",
                ),
              ],
            ),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            _buildFAQCategory(
              title: "Technical Support",
              count: "2",
              initiallyExpanded: false,
              children: [
                _buildFAQItem(
                  question: "How do I reset my headset?",
                  answer:
                      "Press and hold the power button for 10 seconds until the LED light flashes red and blue.",
                ),
                _buildFAQItem(
                  question: "App is crashing constantly",
                  answer:
                      "Please ensure you have the latest version installed. If the problem persists, try reinstalling the app.",
                ),
              ],
            ),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory({
    required String title,
    required String count,
    required bool initiallyExpanded,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // Remove borders
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "($count questions)",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        iconColor: Colors.black87,
        collapsedIconColor: Colors.black87,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        children: children,
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
