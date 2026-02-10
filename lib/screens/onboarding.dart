import 'package:flutter/material.dart';
import '../utils/style.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/icon/onboarding1.gif',
      'title': 'Selamat Datang',
      'text': 'Bersiaplah untuk memulai petualangan',
    },
    {
      'image': 'assets/icon/furirun.gif',
      'title': 'EFISIENSI',
      'text': 'Tingkatkan Produktivitas Dengan Pengalaman Yang Menarik',
    },
    {
      'image': 'assets/icon/splashicon.gif',
      'title': 'Mulai',
      'text': 'Jadi Lebih Disiplin Bersama Kami',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _fadeController.reset();
      _scaleController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      Future.delayed(const Duration(milliseconds: 200), () {
        _fadeController.forward();
        _scaleController.forward();
      });
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _fadeController.reset();
      _scaleController.reset();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      Future.delayed(const Duration(milliseconds: 200), () {
        _fadeController.forward();
        _scaleController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/background4.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Overlay untuk membuat teks lebih terbaca
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4)),
          child: SafeArea(
            child: Column(
              children: [
                // 1. Header: Icon + Dungeon List
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icon/splashicon.gif',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Dungeon List',
                        style: withBorder(
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1.0,
                          ),
                          outlineWidth: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 2. Icon GIF
                                Image.asset(
                                  _pages[index]['image']!,
                                  height: 280,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 40),

                                // 3. Text (Title + Description)
                                Column(
                                  children: [
                                    // Title
                                    Text(
                                      _pages[index]['title']!,
                                      textAlign: TextAlign.center,
                                      style: withBorder(
                                        const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                          height: 1.3,
                                        ),
                                        outlineWidth: 2.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Description
                                    Text(
                                      _pages[index]['text']!,
                                      textAlign: TextAlign.center,
                                      style: withBorder(
                                        const TextStyle(
                                          height: 1.6,
                                          fontSize: 16,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                        outlineWidth: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 4. Navigation Buttons (Next/Previous)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: _currentPage == index ? 40 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Navigation Buttons
                      Row(
                        children: [
                          // Previous Button
                          if (_currentPage > 0)
                            Expanded(
                              child: _NavigationButton(
                                onPressed: _previousPage,
                                label: '',
                                icon: Icons.arrow_back_rounded,
                                isPrimary: false,
                              ),
                            ),

                          if (_currentPage > 0) const SizedBox(width: 16),

                          // Next / Start Button
                          Expanded(
                            child: _NavigationButton(
                              onPressed: _nextPage,
                              label: _currentPage == _pages.length - 1
                                  ? ''
                                  : '',
                              icon: _currentPage == _pages.length - 1
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              isPrimary: true,
                              iconRight: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Navigation Button Component
class _NavigationButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool iconRight;

  const _NavigationButton({
    this.onPressed,
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.iconRight = false,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.iconRight
                ? [
                    Text(
                      widget.label,
                      style: withBorder(
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        outlineWidth: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(widget.icon, color: Colors.white, size: 22),
                  ]
                : [
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: withBorder(
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        outlineWidth: 1.5,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
