
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class FruitBoxGame extends StatefulWidget {
  const FruitBoxGame({super.key});

  @override
  State<FruitBoxGame> createState() => _FruitBoxGameState();
}

class _FruitBoxGameState extends State<FruitBoxGame> {
  Timer? _timer;
  double fruitX = 0.5;
  double fruitY = 0.0;
  double boxX = 0.5;
  int score = 0;
  bool isPlaying = false;
  bool gameOver = false;

  static const double fruitStep = 0.02;

  @override
  void initState() {
    super.initState();
    _resetFruit();
  }

  void _startGame() {
    score = 0;
    boxX = 0.5;
    _resetFruit();
    isPlaying = true;
    gameOver = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _update());
  }

  void _resetFruit() {
    final rng = Random();
    fruitX = rng.nextDouble();
    fruitY = 0.0;
  }

  void _update() {
    setState(() {
      fruitY += fruitStep;
      if (fruitY >= 1.0) {
        if ((fruitX - boxX).abs() < 0.1) {
          score += 1;
          _resetFruit();
        } else {
          isPlaying = false;
          gameOver = true;
          _timer?.cancel();
        }
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (!isPlaying) {
          _startGame();
        }
      },
      onHorizontalDragUpdate: isPlaying
          ? (details) {
              setState(() {
                boxX += details.delta.dx / width;
                boxX = boxX.clamp(0.0, 1.0);
              });
            }
          : null,
      child: Stack(
        children: [
          Positioned(
            left: fruitX * width - 20,
            top: fruitY * height,
            child: CustomPaint(
              painter: _ApplePainter(),
              size: const Size(40, 40),
            ),
          ),
          Positioned(
            left: boxX * width - 40,
            bottom: 20,
            child: Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              "Score: $score",
              style: const TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          if (!isPlaying)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Text(
                    gameOver ? 'Game Over\nTap to Restart' : 'Tap to Start',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ApplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.shade700;
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.2);
    path.cubicTo(
      size.width * 0.8,
      0,
      size.width,
      size.height * 0.6,
      size.width * 0.5,
      size.height,
    );
    path.cubicTo(
      0,
      size.height * 0.6,
      size.width * 0.2,
      0,
      size.width * 0.5,
      size.height * 0.2,
    );
    canvas.drawPath(path, paint);

    final highlight = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.35),
      size.width * 0.15,
      highlight,
    );

    final leafPaint = Paint()..color = Colors.green.shade600;
    final leafPath = Path();
    leafPath.moveTo(size.width * 0.55, size.height * 0.15);
    leafPath.quadraticBezierTo(
      size.width * 0.7,
      size.height * -0.05,
      size.width * 0.65,
      size.height * 0.25,
    );
    leafPath.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.05,
      size.width * 0.55,
      size.height * 0.15,
    );
    canvas.drawPath(leafPath, leafPaint);

    final stemPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.05),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
