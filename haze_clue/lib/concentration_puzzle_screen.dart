import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart'; // For colors

class ConcentrationPuzzleScreen extends StatefulWidget {
  const ConcentrationPuzzleScreen({super.key});

  @override
  State<ConcentrationPuzzleScreen> createState() =>
      _ConcentrationPuzzleScreenState();
}

class _ConcentrationPuzzleScreenState extends State<ConcentrationPuzzleScreen> {
  bool _binauralBeatsEnabled = true;

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
          "Concentration Puzzle",
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
          children: [
            // --- Game Board Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Score & Time Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Focus Score",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            "785",
                            style: TextStyle(
                              color: kPrimaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Time Left",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            "03:45",
                            style: TextStyle(
                              color: kPrimaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3x3 Grid
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildGridItem("1", isDark: false),
                          _buildGridItem("2", isDark: true),
                          _buildGridItem("3", isDark: false),
                          _buildGridItem("4", isDark: true),
                          _buildGridItem("5", isDark: false),
                          _buildGridItem("6", isDark: true),
                          _buildGridItem("7", isDark: false),
                          _buildGridItem("8", isDark: true),
                          _buildGridItem("9", isDark: false),
                        ],
                      ),
                      // Floating target icon decoration
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: kPrimaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.adjust,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Stats Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      "Current Combo",
                      style: TextStyle(color: kTextLightGrey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "12x",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kTextDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                Column(
                  children: [
                    const Text(
                      "Accuracy",
                      style: TextStyle(color: kTextLightGrey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "92%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kTextDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Binaural Beats Toggle ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headphones, color: kPrimaryPurple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Binaural Beats",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: _binauralBeatsEnabled,
                    activeColor: kPrimaryPurple,
                    onChanged: (val) {
                      setState(() {
                        _binauralBeatsEnabled = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- AI Tips Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: kPrimaryPurple, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "AI Tips",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kTextDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Maintain consistent tapping rhythm for higher accuracy bonuses. Deep breaths help!",
                    style: TextStyle(
                      color: kTextLightGrey,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String number, {required bool isDark}) {
    // Alternating shades of purple similar to the design
    Color bgColor = isDark
        ? kPrimaryPurple.withOpacity(0.5) // Lighter shade
        : kPrimaryPurple; // Normal shade

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kPrimaryPurple.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
