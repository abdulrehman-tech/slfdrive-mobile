import 'package:flutter/material.dart';

class AdItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradient;

  const AdItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradient,
  });
}
