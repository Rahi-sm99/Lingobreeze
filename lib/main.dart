import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const PirateQuestApp());
}

// ==========================================
//               CONFIG & THEME
// ==========================================

class PirateQuestApp extends StatelessWidget {
  const PirateQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pirate Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        useMaterial3: true,
        fontFamily: 'Arial',
        // Define a consistent text theme for the app
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            height: 1.4,
            color: Colors.white54,
          ),
          labelLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

class AppColors {
  static const Color background = Color(0xFF0B1623);
  static const Color primary = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color accentOrange = Color(0xFFB45309);
  static const Color planetBase = Color(0xFF84CC16);
  static const Color planetDark = Color(0xFF65A30D);
  static const Color containerBg = Color(0xFF1A2634);
  static const Color containerBorder = Color(0xFF233040);
}

class AppAssets {
  static const String hoppie = 'assets/hoppie.png';
  static const String moksh = 'assets/moksh.png';
  static const String merlin = 'assets/merlin.png';
  static const String hat = 'assets/hat.png';
  static const String boat = 'assets/boat.png';
}

// ==========================================
//                  MODELS
// ==========================================

class OnboardingContent {
  final String title;
  final String subTitle;
  final String description;
  final String imagePath;
  final String characterName;

  const OnboardingContent({
    required this.title,
    required this.subTitle,
    required this.description,
    required this.imagePath,
    required this.characterName,
  });

  static const List<OnboardingContent> data = [
    OnboardingContent(
      title: "AHOY!",
      subTitle: "Welcome aboard!",
      description: "Learn Language as you sail through islands of adventure!",
      imagePath: AppAssets.hoppie,
      characterName: "HOPPIE",
    ),
    OnboardingContent(
      title: "FOCUS!",
      subTitle: "Your Mind!",
      description: "Master words, unlock treasures and level up your journey.",
      imagePath: AppAssets.moksh,
      characterName: "MOKSH",
    ),
    OnboardingContent(
      title: "PREPARE!",
      subTitle: "For the Quest!",
      description: "Face tougher challenges, earn rare rewards & rise as a true language warrior.",
      imagePath: AppAssets.merlin,
      characterName: "MERLIN",
    ),
    OnboardingContent(
      title: "JOURNEY!",
      subTitle: "Awaits!",
      description: "",
      imagePath: AppAssets.hoppie,
      characterName: "LingoBreeze",
    ),
  ];
}

// ==========================================
//               SCREENS
// ==========================================

/// Screen 1: The main Onboarding flow with the rotating planet.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  double _pageProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(_onScroll);
  }

  void _onScroll() {
    // Determine the precise scroll position for smooth animations
    setState(() {
      _pageProgress = _pageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < OnboardingContent.data.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLanguageSelection();
    }
  }

  void _navigateToLanguageSelection() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LanguageSelectionScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentIndex == OnboardingContent.data.length - 1;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Rotating Planet Background
          RotatingPlanetBackground(
            scrollProgress: _pageProgress,
            visibleHeight: 180.0, // Keeping the valley small as requested
          ),

          // 2. Main Swipeable Content
          Positioned.fill(
            bottom: 120, // Padding to avoid overlap with planet/button
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: OnboardingContent.data.length,
              itemBuilder: (context, index) {
                return OnboardingPageItem(
                  content: OnboardingContent.data[index],
                  isLastPage: index == OnboardingContent.data.length - 1,
                );
              },
            ),
          ),

          // 3. Action Button (Morphing)
          Positioned(
            bottom: 30,
            child: MorphingActionButton(
              isExpanded: isLastPage,
              onTap: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 2: Language Selection with Boat Animation
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _waveController;
  late final AnimationController _boatEntranceController;
  late final AnimationController _gridStaggerController;

  // Animations
  late final Animation<Offset> _boatSlideAnimation;
  late final Animation<double> _boatBobAnimation;
  late final Animation<double> _boatWiggleAnimation;

  final List<String> languages = [
    "हिन्दी", "English", "मराठी", "தமிழ்",
    "اردو", "తెలుగు", "ಕನ್ನಡ", "മലയാളം", "English"
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Continuous Wave Loop
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Boat Entrance (One-off)
    _boatEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Grid Stagger (One-off)
    _gridStaggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Definitions
    _boatSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _boatEntranceController,
      curve: Curves.easeOutCubic,
    ));

    _boatBobAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: const SineCurve(duration: 4.0),
      ),
    );

    _boatWiggleAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _boatEntranceController.forward();
    _gridStaggerController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _boatEntranceController.dispose();
    _gridStaggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Language Grid
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: LanguageGrid(
              languages: languages,
              staggerController: _gridStaggerController,
            ),
          ),

          // 2. Speech Bubble
          Positioned(
            top: 350,
            left: 40,
            right: 40,
            height: 120,
            child: FadeTransition(
              opacity: _boatEntranceController,
              child: const CustomPaint(
                painter: SpeechBubblePainter(),
              ),
            ),
          ),

          // 3. Waves Background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: WaveBackground(controller: _waveController),
          ),

          // 4. Boat Scene
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _boatSlideAnimation,
              child: BoatScene(
                bobAnimation: _boatBobAnimation,
                wiggleAnimation: _boatWiggleAnimation,
              ),
            ),
          ),

          // 5. Continue Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
//              REUSABLE WIDGETS
// ==========================================

/// Displays a single page of content in the onboarding flow
class OnboardingPageItem extends StatelessWidget {
  final OnboardingContent content;
  final bool isLastPage;

  const OnboardingPageItem({
    super.key,
    required this.content,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              content.title,
              key: ValueKey(content.title),
              textAlign: TextAlign.center,
              style: textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.subTitle,
            textAlign: TextAlign.center,
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              content.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 40),
          CharacterDisplay(
            imagePath: content.imagePath,
            isLastPage: isLastPage,
          ),
          const SizedBox(height: 30),
          Text(
            content.characterName,
            style: textTheme.labelLarge, // Ensures white color
          ),
        ],
      ),
    );
  }
}

/// The circular character avatar with a static image
class CharacterDisplay extends StatelessWidget {
  final String imagePath;
  final bool isLastPage;

  const CharacterDisplay({
    super.key,
    required this.imagePath,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHoppie = imagePath == AppAssets.hoppie;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background effect for final screen
        if (isLastPage)
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.teal.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),

        // Main Container Frame
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.containerBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.containerBorder, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                imagePath,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                key: ValueKey(imagePath),
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 80, color: Colors.white24);
                },
              ),
              if (isHoppie)
                Positioned(
                  top: -40,
                  child: Image.asset(
                    AppAssets.hat,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const SizedBox(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The massive rotating planet/valley at the bottom of the screen
class RotatingPlanetBackground extends StatelessWidget {
  final double scrollProgress;
  final double visibleHeight;

  const RotatingPlanetBackground({
    super.key,
    required this.scrollProgress,
    required this.visibleHeight,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Calculate diameter based on width to ensure consistent curvature on all devices
    final double planetDiameter = size.width * 2.5;

    return Positioned(
      bottom: -planetDiameter + visibleHeight,
      left: (size.width - planetDiameter) / 2,
      width: planetDiameter,
      height: planetDiameter,
      child: Transform.rotate(
        // Rotate based on scroll progress (counter-clockwise)
        angle: -scrollProgress * (math.pi / 4),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.planetBase,
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              // Inner darker layer for depth
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.planetDark.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Decorative "Craters" to visualize rotation
              _buildCraterPositioned(top: 50, left: planetDiameter / 2 - 50, size: 80),
              _buildCraterPositioned(top: 200, right: 150, size: 120),
              _buildCraterPositioned(top: 150, left: 200, size: 60),
              _buildCraterPositioned(bottom: 300, left: 300, size: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCraterPositioned({double? top, double? bottom, double? left, double? right, required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.planetDark.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// The button that morphs from an arrow to a "Get Started" text button
class MorphingActionButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const MorphingActionButton({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutBack,
        width: isExpanded ? 240 : 70,
        height: 70,
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white : AppColors.accentOrange,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: isExpanded
              ? const Text(
            "Lets Get Started",
            key: ValueKey(true),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )
              : const Icon(
            Icons.arrow_forward,
            key: ValueKey(false),
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

/// The complex boat scene composition for Screen 2
class BoatScene extends StatelessWidget {
  final Animation<double> bobAnimation;
  final Animation<double> wiggleAnimation;

  const BoatScene({
    super.key,
    required this.bobAnimation,
    required this.wiggleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([bobAnimation, wiggleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, bobAnimation.value),
          child: Transform.rotate(
            angle: wiggleAnimation.value,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          height: 240,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Opacity(
                opacity: 0.9,
                child: Image.asset(
                  AppAssets.boat,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                right: 0,
                child: Center(
                  child: Image.asset(
                    AppAssets.hoppie,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    AppAssets.hat,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of language options
class LanguageGrid extends StatelessWidget {
  final List<String> languages;
  final AnimationController staggerController;

  const LanguageGrid({
    super.key,
    required this.languages,
    required this.staggerController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        // Create staggered animation for each item
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: staggerController,
            curve: Interval(
              (index / languages.length) * 0.5,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animation.value)),
                child: child,
              ),
            );
          },
          child: Center(
            child: Text(
              languages[index],
              style: TextStyle(
                color: languages[index] == "English"
                    ? AppColors.primary
                    : Colors.white54,
                fontSize: 22,
                fontWeight: languages[index] == "English"
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Composes two wave layers
class WaveBackground extends StatelessWidget {
  final AnimationController controller;

  const WaveBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildLayer(opacity: 0.3, offset: 0, color: AppColors.primary),
        _buildLayer(opacity: 0.5, offset: math.pi, color: AppColors.primaryDark, bottomOffset: -10),
      ],
    );
  }

  Widget _buildLayer({
    required double opacity,
    required double offset,
    required Color color,
    double bottomOffset = 0,
  }) {
    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      height: 150,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(
              animationValue: controller.value,
              offset: offset,
              color: color.withOpacity(opacity),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
//               PAINTERS & CURVES
// ==========================================

class SpeechBubblePainter extends CustomPainter {
  const SpeechBubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9D9D9)
      ..style = PaintingStyle.fill;

    final path = Path();
    double radius = 20.0;
    double tailWidth = 20.0;
    double tailHeight = 20.0;
    double tailPosition = size.width / 2 - 40;

    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - tailHeight),
        Radius.circular(radius)));

    path.moveTo(tailPosition, size.height - tailHeight);
    path.lineTo(tailPosition + tailWidth / 2, size.height);
    path.lineTo(tailPosition + tailWidth, size.height - tailHeight);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double offset;
  final Color color;

  const WavePainter({
    required this.animationValue,
    this.offset = 0,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    // Start slightly below center
    double waveHeight = 20;
    double baseHeight = size.height;

    path.moveTo(0, baseHeight);
    path.lineTo(0, waveHeight);

    // Draw sine wave
    for (double i = 0; i <= size.width; i++) {
      double dx = i;
      double dy = waveHeight *
          math.sin((i / size.width * 2 * math.pi) +
              (animationValue * 2 * math.pi) +
              offset) +
          waveHeight;
      path.lineTo(dx, dy);
    }

    path.lineTo(size.width, baseHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class SineCurve extends Curve {
  const SineCurve({this.duration = 1.0});
  final double duration;

  @override
  double transformInternal(double t) {
    return math.sin(math.pi * 2 * (t * (1 / duration)));
  }
}