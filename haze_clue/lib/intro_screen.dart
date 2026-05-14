import 'package:flutter/material.dart';
import 'main.dart';
import 'sign_in_screen.dart';
import 'shared_widgets.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Map<String, String>> _contents = [
    {
      'image': 'assets/images/Intro.png',
      'title': "Unlock your\nMind’s potential",
      'desc': "",
    },
    {
      'image': 'assets/images/Intro1.png',
      'title': "Understand Your\nBrain In Real Time",
      'desc':
          "Advanced EEG analysis for focus, engagement, and cognitive clarity.",
    },
    {
      'image': 'assets/images/Intro2.png',
      'title': "Personalized Stimulation\nFor Peak Performance",
      'desc':
          "Adaptive TDCS and binaural beats tailored to your brain's activity.",
    },
  ];

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Minimal top padding to keep everything high
            const SizedBox(height: 10),

            // --- ENLARGED LOGO ---
            Center(
              child: Image.asset(
                'assets/images/hazecluelogo.jpeg',
                height: 160, // Increased size
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.red);
                },
              ),
            ),

            // Expanded holds the carousel and text
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // The illustration - uses less flex to pull text up
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            _contents[index]['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 10), // Tightened gap

                        Text(
                          _contents[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kTextDark,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),

                        if (_contents[index]['desc']!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _contents[index]['desc']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kTextLightGrey,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],

                        // This spacer pushes the text/image block upward
                        const Spacer(flex: 1),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Controls anchored to the bottom but with tighter margins
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  PrimaryButton(
                    text: _currentIndex == _contents.length - 1
                        ? "Get started"
                        : "Next",
                    onPressed: () {
                      if (_currentIndex == _contents.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? kPrimaryPurple
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
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
}
