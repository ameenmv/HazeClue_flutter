import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math';
import 'glass_widgets.dart';

class ConcentrationPuzzleScreen extends StatefulWidget {
  const ConcentrationPuzzleScreen({super.key});

  @override
  State<ConcentrationPuzzleScreen> createState() =>
      _ConcentrationPuzzleScreenState();
}

class _ConcentrationPuzzleScreenState extends State<ConcentrationPuzzleScreen> {
  bool _binauralBeatsEnabled = true;

  // Game State
  bool _isPlaying = false;
  int _score = 0;
  int _timeLeft = 30;
  int _combo = 0;
  int _activeTargetIndex = -1;
  int _correctTaps = 0;
  int _totalTaps = 0;

  Timer? _gameTimer;
  Timer? _targetTimer;
  final Random _random = Random();

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _timeLeft = 30;
      _combo = 0;
      _correctTaps = 0;
      _totalTaps = 0;
      _moveTarget();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _activeTargetIndex = -1;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Time's Up!", style: TextStyle(color: Colors.white)),
        content: Text("Your Focus Score is $_score\nAccuracy: ${(_accuracy * 100).toInt()}%", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("OK", style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }

  void _moveTarget() {
    _targetTimer?.cancel();
    setState(() {
      _activeTargetIndex = _random.nextInt(9);
    });
    // Target moves on its own if not tapped quickly enough
    _targetTimer = Timer(const Duration(milliseconds: 1200), () {
      if (_isPlaying) {
        setState(() {
          _combo = 0; // Missed target
        });
        _moveTarget();
      }
    });
  }

  void _onGridTapped(int index) {
    if (!_isPlaying) return;

    setState(() {
      _totalTaps++;
      if (index == _activeTargetIndex) {
        // Hit
        _correctTaps++;
        _combo++;
        _score += 10 * _combo;
        _moveTarget();
      } else {
        // Miss
        _combo = 0;
      }
    });
  }

  double get _accuracy => _totalTaps == 0 ? 1.0 : _correctTaps / _totalTaps;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Concentration Puzzle",
          style: TextStyle(
            color: Colors.white,
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
              children: [
                // --- Game Board Card ---
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
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
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "$_score",
                                  style: const TextStyle(
                                    color: Color(0xFF8B5CF6),
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
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "00:${_timeLeft.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: _timeLeft <= 5 ? Colors.redAccent : const Color(0xFF8B5CF6),
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
                              children: List.generate(9, (index) {
                                return GestureDetector(
                                  onTap: () => _onGridTapped(index),
                                  child: _buildGridItem("${index + 1}", 
                                      isDark: index % 2 != 0, 
                                      isActive: index == _activeTargetIndex),
                                );
                              }),
                            ),
                            // Floating target icon decoration
                            if (!_isPlaying)
                              Positioned(
                                bottom: -10,
                                right: -10,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ],
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
                ),
                const SizedBox(height: 32),

                // --- Stats Row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Current Combo",
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_combo}x",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Column(
                      children: [
                        Text(
                          "Accuracy",
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${(_accuracy * 100).toInt()}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- Binaural Beats Toggle ---
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.headphones, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Binaural Beats",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        CupertinoSwitch(
                          value: _binauralBeatsEnabled,
                          activeColor: const Color(0xFF8B5CF6),
                          thumbColor: Colors.white,
                          trackColor: Colors.white.withOpacity(0.2),
                          onChanged: (val) {
                            setState(() {
                              _binauralBeatsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- AI Tips Card ---
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: Color(0xFF8B5CF6), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "AI Tips",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Maintain consistent tapping rhythm for higher accuracy bonuses. Deep breaths help!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            height: 1.4,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // --- Play Button ---
                if (!_isPlaying)
                  GlassButton(
                    text: "Start Game",
                    icon: Icons.play_arrow,
                    onPressed: _startGame,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(String number, {required bool isDark, required bool isActive}) {
    Color bgColor = isActive 
        ? Colors.orangeAccent // Active target color
        : (isDark ? const Color(0xFF8B5CF6).withOpacity(0.5) : const Color(0xFF8B5CF6).withOpacity(0.8));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(isActive ? 0.8 : 0.2)),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
