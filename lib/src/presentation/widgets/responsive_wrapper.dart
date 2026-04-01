import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wrapper that constrains the app to mobile size on web/desktop
/// and centers it on the screen
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxMobileWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxMobileWidth = 430,
  });

  @override
  Widget build(BuildContext context) {
    // Only apply wrapper on web and desktop platforms
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux) {
      
      return Container(
        color: Colors.black,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxMobileWidth,
            ),
            child: child,
          ),
        ),
      );
    }

    // On mobile, return child as-is
    return child;
  }
}
