import 'package:flutter/material.dart';
import '../../../../../constants/image_constants.dart';

/// Hero background image + darkening gradient overlay shared by mobile and
/// desktop layouts. Gradient stops differ slightly per layout so the caller
/// passes its own.
class PreLoginBackground extends StatelessWidget {
  final List<double> stops;
  final List<Color> colors;

  const PreLoginBackground({super.key, required this.stops, required this.colors});

  const PreLoginBackground.mobile({super.key})
    : stops = const [0.0, 0.45, 0.72, 1.0],
      colors = const [Color(0x1A000000), Color(0x33000000), Color(0xCC000000), Color(0xFF000000)];

  const PreLoginBackground.desktop({super.key})
    : stops = const [0.0, 0.4, 0.7, 1.0],
      colors = const [Color(0x1A000000), Color(0x4D000000), Color(0xCC000000), Color(0xFF000000)];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(ImageConstants.preloginGif, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: stops,
              colors: colors,
            ),
          ),
        ),
      ],
    );
  }
}
