import 'package:flutter/material.dart';

/// Corporate organization that customers may apply to be associated with.
///
/// `domain` is used as a soft hint when validating work emails on the apply
/// form. `accentColor` drives the org chip / picker visuals.
class Organization {
  final String id;
  final String name;
  final String logoUrl;
  final String industry;
  final String domain;
  final Color accentColor;

  const Organization({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.industry,
    required this.domain,
    required this.accentColor,
  });
}
