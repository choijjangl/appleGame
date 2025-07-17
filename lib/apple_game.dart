import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AppleGame extends StatefulWidget {
  const AppleGame({super.key});

  @override
  State<AppleGame> createState() => _AppleGameState();
}

class _AppleGameState extends State<AppleGame> {
  late Timer _timer;
  double appleX = 0.5;
  double appleY = 0.0;
  double basketX = 0.5;
  int score = 0;

  static const double appleStep = 0.02;

  @override
  void initState() {
    super.initState();
    _resetApple();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _update());
  }

  void _resetApple() {
    final rng = Random();
    appleX = rng.nextDouble();
    appleY = 0.0;
  }

  void _update() {
    setState(() {
      appleY += appleStep;
      if (appleY >= 1.0) {
        if ((appleX - basketX).abs() < 0.1) {
          score += 1;
        }
        _resetApple();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          basketX += details.delta.dx / width;
          basketX = basketX.clamp(0.0, 1.0);
        });
      },
      child: Stack(
        children: [
          Positioned(
            left: appleX * width - 15,
            top: appleY * height,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: basketX * width - 30,
            bottom: 20,
            child: Container(
              width: 60,
              height: 20,
              color: Colors.brown,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
