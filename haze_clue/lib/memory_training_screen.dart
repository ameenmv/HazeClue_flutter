import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart'; // For colors

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
        title: const Text("Training Complete!"),
        content: Text("You found all matches in $_moves moves.\nGreat job exercising your memory!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _initializeGame(); // Restart game
              });
            },
            child: const Text("Play Again", style: TextStyle(color: kPrimaryPurple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to training screen
            },
            child: const Text("Exit", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

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
          "Memory Training",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Moves",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "$_moves",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryPurple),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Matches",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "$_matches / 8",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryPurple),
                      ),
                    ],
                  ),
                ],
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
                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _isFlipped[index] || _isMatched[index] 
                              ? kPrimaryPurple.withOpacity(0.1) 
                              : kPrimaryPurple,
                          borderRadius: BorderRadius.circular(12),
                          border: _isFlipped[index] || _isMatched[index]
                              ? Border.all(color: kPrimaryPurple, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: _isFlipped[index] || _isMatched[index]
                              ? Icon(
                                  _cardIcons[index],
                                  size: 32,
                                  color: kPrimaryPurple,
                                )
                              : const Icon(
                                  Icons.help_outline,
                                  size: 32,
                                  color: Colors.white70,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Restart Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Restart Game",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
