import 'package:flutter/material.dart';
import 'main.dart'; // For colors

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ["All", "EEG", "Smartwatch", "tDCS"];

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
          "My Devices",
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
            // --- Device Categories ---
            const Text(
              "Device Categories",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _categories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: _selectedCategory == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      selectedColor: kPrimaryPurple,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedCategory == index
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedCategory == index
                              ? kPrimaryPurple
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Connected Devices ---
            const Text(
              "Connected Devices",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildConnectedDeviceItem(
              icon: Icons.psychology_outlined,
              name: "HazeFlow EEG",
              model: "Model X-Pro",
              battery: "ca. 85%",
              signal: "excellent",
            ),
            const SizedBox(height: 16),
            _buildConnectedDeviceItem(
              icon: Icons.watch_outlined,
              name: "NeuroSense Watch",
              model: "Series 5",
              battery: "ca. 58%",
              signal: "good",
            ),
            const SizedBox(height: 32),

            // --- Available Devices ---
            const Text(
              "Available Devices",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "Scan for Devices",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildAvailableDeviceItem(
              icon: Icons.bolt,
              name: "FocusStim Headset",
              signal: "fair",
            ),
            const SizedBox(height: 16),
            _buildAvailableDeviceItem(
              icon: Icons.psychology,
              name: "MindLink EEG",
              signal: "good",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceItem({
    required IconData icon,
    required String name,
    required String model,
    required String battery,
    required String signal,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    fontSize: 15,
                  ),
                ),
                Text(
                  model,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.battery_charging_full,
                        size: 14, color: kSuccessGreen),
                    const SizedBox(width: 4),
                    Text(
                      battery,
                      style: const TextStyle(
                          color: kSuccessGreen, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.wifi, size: 14, color: kSuccessGreen),
                    const SizedBox(width: 4),
                    const Text(
                      "Connected",
                      style: TextStyle(
                          color: kSuccessGreen, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.signal_cellular_alt,
                        size: 14, color: kSuccessGreen),
                    const SizedBox(width: 4),
                    Text(
                      signal,
                      style: const TextStyle(
                          color: kSuccessGreen, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.settings_outlined, color: Colors.black87, size: 20),
          const SizedBox(width: 12),
          const Icon(Icons.remove_red_eye_outlined,
              color: Colors.black87, size: 20),
        ],
      ),
    );
  }

  Widget _buildAvailableDeviceItem({
    required IconData icon,
    required String name,
    required String signal,
  }) {
    Color signalColor = signal == 'good' ? kSuccessGreen : Colors.orangeAccent;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.wifi_off, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  const Text(
                    "Disconnected",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.signal_cellular_alt, size: 14, color: signalColor),
                  const SizedBox(width: 4),
                  Text(
                    signal,
                    style: TextStyle(color: signalColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            "Connect",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
