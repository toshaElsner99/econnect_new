import 'package:e_connect/utils/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class AchievementPopup extends StatefulWidget {
  final String title;
  final String description;
  final String achievementType;
  final VoidCallback onClose;

  const AchievementPopup({
    super.key,
    required this.title,
    required this.description,
    required this.achievementType,
    required this.onClose,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getLottieAsset() {
    // switch (widget.achievementType.toLowerCase()) {
    // case 'milestone':
    //   return 'assets/animations/milestone.json';
    // case 'performance':
    //   return 'assets/animations/performance.json';
    // case 'teamwork':
    //   return 'assets/animations/teamwork.json';
    // default:
    return AppImage.wafflePNG;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti background
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: math.pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            shouldLoop: true,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),

        // Main content
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie animation
                    SizedBox(
                      height: 100,
                      child: Image.asset(
                        _getLottieAsset(),
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Material(
                      color: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Description
                    Material(
                      color: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Close button
                    ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyAPp extends StatefulWidget {
  const MyAPp({super.key});

  @override
  State<MyAPp> createState() => _MyAPpState();
}

class _MyAPpState extends State<MyAPp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AchievementPopup(
                  title: 'Congratulations! 🎉',
                  description: 'You\'ve earned a new achievement!',
                  achievementType: 'milestone', // or 'performance', 'teamwork', 'celebration'
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
            child: Text(
              'Press the button to see the achievement popup!',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ));
  }
}
