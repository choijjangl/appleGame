import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class FruitBoxGame extends StatefulWidget {
  const FruitBoxGame({super.key});

  @override
  State<FruitBoxGame> createState() => _FruitBoxGameState();
}

class _FruitBoxGameState extends State<FruitBoxGame> {
  static const int rows = 17;
  static const int cols = 10;
  static const Duration gameDuration = Duration(minutes: 2);

  late List<List<int?>> _apples;
  Timer? _timer;
  Duration _timeLeft = gameDuration;
  bool _playing = false;
  bool _gameOver = false;
  int _score = 0;

  Offset? _dragStart;
  Offset? _dragCurrent;

  @override
  void initState() {
    super.initState();
    _generateApples();
  }

  void _generateApples() {
    final rng = Random();
    _apples = List.generate(
      rows,
      (_) => List.generate(cols, (_) => rng.nextInt(9) + 1),
    );
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = gameDuration;
      _gameOver = false;
      _playing = true;
      _generateApples();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_timeLeft > Duration.zero) {
            _timeLeft -= const Duration(seconds: 1);
            if (_timeLeft <= Duration.zero) {
              _playing = false;
              _gameOver = true;
              _timer?.cancel();
            }
          }
        });
      });
    });
  }

  void _endDrag() {
    if (_dragStart == null || _dragCurrent == null) return;
    final rect = Rect.fromPoints(_dragStart!, _dragCurrent!);
    final selected = <Point<int>>[];
    int sum = 0;
    final size = context.size;
    if (size == null) return;
    final cellW = size.width - 40;
    final cellH = size.height;
    final w = cellW / cols;
    final h = cellH / rows;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final val = _apples[r][c];
        if (val == null) continue;
        final appleRect = Rect.fromLTWH(c * w, r * h, w, h);
        if (rect.overlaps(appleRect)) {
          selected.add(Point(c, r));
          sum += val;
        }
      }
    }
    if (sum == 10) {
      for (final p in selected) {
        if (_apples[p.y][p.x] != null) {
          _apples[p.y][p.x] = null;
          _score += 1;
        }
      }
    }
    _dragStart = null;
    _dragCurrent = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_playing) _startGame();
      },
      onPanStart: _playing
          ? (d) => setState(() {
                _dragStart = d.localPosition;
                _dragCurrent = d.localPosition;
              })
          : null,
      onPanUpdate: _playing
          ? (d) => setState(() => _dragCurrent = d.localPosition)
          : null,
      onPanEnd: _playing
          ? (_) => setState(() {
                _endDrag();
              })
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - 40;
          final height = constraints.maxHeight;
          final cellW = width / cols;
          final cellH = height / rows;

          Rect? dragRect;
          bool valid = false;
          if (_dragStart != null && _dragCurrent != null) {
            dragRect = Rect.fromPoints(_dragStart!, _dragCurrent!);
            int sum = 0;
            for (int r = 0; r < rows; r++) {
              for (int c = 0; c < cols; c++) {
                final val = _apples[r][c];
                if (val == null) continue;
                final appleRect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
                if (dragRect.overlaps(appleRect)) {
                  sum += val;
                }
              }
            }
            valid = sum == 10;
          }

          return Stack(
            children: [
              for (int r = 0; r < rows; r++)
                for (int c = 0; c < cols; c++)
                  if (_apples[r][c] != null)
                    Positioned(
                      left: c * cellW,
                      top: r * cellH,
                      width: cellW,
                      height: cellH,
                      child: _Apple(value: _apples[r][c]!),
                    ),
              if (dragRect != null)
                Positioned.fromRect(
                  rect: dragRect,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: valid ? Colors.red : Colors.brown, width: 2),
                      color: valid ? Colors.red.withOpacity(0.2) : Colors.brown.withOpacity(0.1),
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                left: 20,
                child: Text(
                  'Score: \$_score',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                width: 20,
                height: height,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  child: FractionallySizedBox(
                    heightFactor: _timeLeft.inMilliseconds / gameDuration.inMilliseconds,
                    alignment: Alignment.bottomCenter,
                    child: Container(color: Colors.green),
                  ),
                ),
              ),
              if (!_playing)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Text(
                        _gameOver ? 'Game Over\nTap to Restart' : 'Tap to Start',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, color: Colors.black),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Apple extends StatelessWidget {
  final int value;
  const _Apple({required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _ApplePainter(),
          ),
          Text(
            '$value',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
