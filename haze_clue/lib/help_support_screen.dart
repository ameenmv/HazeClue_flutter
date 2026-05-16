import 'package:flutter/material.dart';
import 'glass_widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help & Support",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                GlassTextField(
                  label: "Search",
                  hint: "Search FAQs...",
                  controller: _searchController,
                  icon: Icons.search,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  "Frequently Asked Questions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Expansion Tiles
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildFAQCategory(
                          title: "General Queries",
                          count: "3",
                          initiallyExpanded: true,
                          textColor: textColor,
                          children: [
                            _buildFAQItem(
                              question: "How do I get started with the EEG App?",
                              answer:
                                  "Download the app from your respective app store, create an account, and follow the on-screen setup instructions to pair your device.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "What devices are compatible with the app?",
                              answer:
                                  "The EEG App is compatible with all major iOS and Android smartphones and tablets running version 12.0 or higher for iOS, and 8.0 or higher for Android. Specific hardware models are listed in the app's settings.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "Is my data secure?",
                              answer:
                                  "Yes, we use industry-standard encryption and security protocols to protect your personal and health data. For more details, please refer to our privacy policy.",
                              textColor: textColor,
                            ),
                          ],
                        ),
                        _buildDivider(textColor),
                        _buildFAQCategory(
                          title: "Technical Support",
                          count: "2",
                          initiallyExpanded: false,
                          textColor: textColor,
                          children: [
                            _buildFAQItem(
                              question: "How do I reset my headset?",
                              answer:
                                  "Press and hold the power button for 10 seconds until the LED light flashes red and blue.",
                              textColor: textColor,
                            ),
                            _buildFAQItem(
                              question: "App is crashing constantly",
                              answer:
                                  "Please ensure you have the latest version installed. If the problem persists, try reinstalling the app.",
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCategory({
    required String title,
    required String count,
    required bool initiallyExpanded,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // Remove borders
        unselectedWidgetColor: textColor.withOpacity(0.5),
        colorScheme: ColorScheme.dark(
          primary: textColor,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
        iconColor: textColor,
        collapsedIconColor: textColor.withOpacity(0.5),
        childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        children: children,
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color textColor) {
    return Divider(
      height: 1,
      thickness: 1,
      color: textColor.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}
