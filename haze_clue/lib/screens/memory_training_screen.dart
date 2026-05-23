import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/glass_widgets.dart';

class MemoryTrainingScreen extends StatefulWidget {
  const MemoryTrainingScreen({super.key});

  @override
  State<MemoryTrainingScreen> createState() => _MemoryTrainingScreenState();
}

class _MemoryTrainingScreenState extends State<MemoryTrainingScreen> {
  final List<IconData> _cardIcons = [
    Icons.favorite, Icons.star, Icons.ac_unit, Icons.anchor,
    Icons.lightbulb, Icons.pets, Icons.rocket, Icons.water_drop,
    Icons.favorite, Icons.star, Icons.ac_unit, Icons.anchor,
    Icons.lightbulb, Icons.pets, Icons.rocket, Icons.water_drop,
  ];

  List<bool> _isFlipped = [];
  List<bool> _isMatched = [];
  List<int> _selectedIndices = [];
  
  bool _isPlaying = false;
  int _moves = 0;
  int _matches = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cardIcons.shuffle();
    _isFlipped = List.generate(16, (index) => false);
    _isMatched = List.generate(16, (index) => false);
    _selectedIndices = [];
    _moves = 0;
    _matches = 0;
    _isPlaying = true;
    _isProcessing = false;
  }

  void _onCardTap(int index) {
    if (!_isPlaying || _isProcessing || _isFlipped[index] || _isMatched[index]) {
      return;
    }

    setState(() {
      _isFlipped[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _moves++;
      _isProcessing = true;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    int index1 = _selectedIndices[0];
    int index2 = _selectedIndices[1];

    if (_cardIcons[index1] == _cardIcons[index2]) {
      // Match found
      setState(() {
        _isMatched[index1] = true;
        _isMatched[index2] = true;
        _selectedIndices.clear();
        _isProcessing = false;
        _matches++;
      });

      if (_matches == 8) {
        _endGame();
      }
    } else {
      // No match, flip back after delay
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _isFlipped[index1] = false;
          _isFlipped[index2] = false;
          _selectedIndices.clear();
          _isProcessing = false;
        });
      });
    }
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Training Complete!", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text("You found all matches in $_moves moves.\nGreat job exercising your memory!", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _initializeGame(); // Restart game
              });
            },
            child: const Text("Play Again", style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to training screen
            },
            child: Text("Exit", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;

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
          "Memory Training",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header Status
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Moves",
                              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_moves",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B5CF6)),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: textColor.withOpacity(0.2),
                        ),
                        Column(
                          children: [
                            Text(
                              "Matches",
                              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_matches / 8",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B5CF6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Game Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      bool isRevealed = _isFlipped[index] || _isMatched[index];
                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isRevealed 
                                ? (isLight ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2))
                                : const Color(0xFF8B5CF6).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRevealed 
                                  ? textColor.withOpacity(0.5) 
                                  : textColor.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: !isRevealed ? [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ] : null,
                          ),
                          child: Center(
                            child: isRevealed
                                ? Icon(
                                    _cardIcons[index],
                                    size: 32,
                                    color: textColor,
                                  )
                                : Icon(
                                    Icons.help_outline,
                                    size: 32,
                                    color: textColor.withOpacity(0.7),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Restart Button
                GlassButton(
                  text: "Restart Game",
                  isOutlined: true,
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
