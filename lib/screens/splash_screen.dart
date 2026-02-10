import 'dart:async';
import 'package:flutter/material.dart';

import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _displayText = "";
  final String _fullText = "Dungeon List";
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        // Wait for a moment after text is complete before navigating
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF212121,
      ), // Dark background for retro feel
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/splashicon.gif', // Verify this path matches actual file
              width: 50, // Adjust size as needed
              height: 50,
            ),
            const SizedBox(width: 20),
            Text(
              _displayText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20, // Adjust size as needed
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
