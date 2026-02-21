import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home.dart';
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
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _navigate();
        });
      }
    });
  }

  void _navigate() {
    // Cek apakah user sudah login sebelumnya
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // Sesi aktif → langsung ke HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QuestLogScreen()),
      );
    } else {
      // Belum login → tampilkan onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon/splashicon.gif', width: 50, height: 50),
            const SizedBox(width: 20),
            Text(
              _displayText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
