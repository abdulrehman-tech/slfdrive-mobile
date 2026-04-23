import 'package:flutter/material.dart';

class BookingQrMockPainter extends CustomPainter {
  final int seed;
  BookingQrMockPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final s = size.width;
    const grid = 12;
    final cell = s / grid;
    final rng = _Rand(seed);
    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        if (rng.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
    final markerPaint = Paint()..color = Colors.black;
    void marker(double dx, double dy) {
      canvas.drawRect(Rect.fromLTWH(dx, dy, cell * 3, cell * 3), markerPaint);
      canvas.drawRect(
        Rect.fromLTWH(dx + cell * 0.6, dy + cell * 0.6, cell * 1.8, cell * 1.8),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(Rect.fromLTWH(dx + cell, dy + cell, cell, cell), markerPaint);
    }

    marker(0, 0);
    marker(s - cell * 3, 0);
    marker(0, s - cell * 3);
  }

  @override
  bool shouldRepaint(covariant BookingQrMockPainter oldDelegate) => false;
}

class _Rand {
  int _state;
  _Rand(int seed) : _state = seed == 0 ? 1 : seed;
  bool nextBool() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return (_state % 2) == 0;
  }
}
