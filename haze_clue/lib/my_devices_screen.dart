import 'package:flutter/material.dart';
import 'main.dart'; // For colors

import 'api_service.dart';

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ["All", "EEG", "Smartwatch", "tDCS"];
  late Future<List<dynamic>> _devicesFuture;
  
  bool _isScanning = false;
  List<Map<String, String>> _scannedDevices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _devicesFuture = ApiService.getDevices();
    });
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scannedDevices.clear();
    });

    // Simulate bluetooth scan delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scannedDevices = [
            {"name": "Muse S (Gen 2)", "mac": "00:11:22:33:44:55"},
            {"name": "NeuroSky MindWave", "mac": "AA:BB:CC:DD:EE:FF"},
          ];
        });
      }
    });
  }

  Future<void> _connectDevice(String name, String mac) async {
    try {
      await ApiService.addDevice(name, mac);
      _loadDevices();
      setState(() {
         // remove it from scanned list if we wanted to be super realistic
         _scannedDevices.removeWhere((d) => d['mac'] == mac);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _removeDevice(String id) async {
    try {
      await ApiService.deleteDevice(id);
      _loadDevices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
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

            const Text(
              "Connected Devices",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _devicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading devices"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No devices connected.");
                }
                final devices = snapshot.data!;
                return Column(
                  children: devices.map((d) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildConnectedDeviceItem(
                        id: d['id'],
                        icon: Icons.psychology_outlined,
                        name: d['name'] ?? "Unknown Device",
                        model: d['macAddress'] ?? "Unknown MAC",
                        battery: "ca. 85%", // mock
                        signal: "good", // mock
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // --- Available Devices ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Available Devices",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: _isScanning 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.bluetooth_searching),
                  label: Text(_isScanning ? "Scanning..." : "Scan"),
                  style: TextButton.styleFrom(foregroundColor: kPrimaryPurple),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (_scannedDevices.isEmpty && !_isScanning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.bluetooth_disabled, color: Colors.grey, size: 40),
                    SizedBox(height: 8),
                    Text("No devices found", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    Text("Tap scan to search for nearby headsets", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ..._scannedDevices.map((device) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildAvailableDeviceItem(
                icon: Icons.psychology,
                name: device['name']!,
                signal: "good",
                onTap: () => _connectDevice(device['name']!, device['mac']!),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceItem({
    required String id,
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
          GestureDetector(
            onTap: () => _removeDevice(id),
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDeviceItem({
    required IconData icon,
    required String name,
    required String signal,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Connect",
                style: TextStyle(
                  color: kPrimaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
