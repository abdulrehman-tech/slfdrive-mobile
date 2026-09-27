import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A company or brand logo loaded from the backend media host, falling back to
/// the first letter of [name] while loading, on error, or when there is no
/// logo yet (most UAT brands have none).
class NetworkLogo extends StatelessWidget {
  final String? url;
  final String name;
  final TextStyle letterStyle;
  final BoxFit fit;

  const NetworkLogo({super.key, required this.url, required this.name, required this.letterStyle, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    final letter = Center(
      child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(), style: letterStyle),
    );
    if (url == null || url!.isEmpty) return letter;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, _) => letter,
      errorWidget: (_, _, _) => letter,
    );
  }
}
