class Brand {
  final String name;

  /// Absolute logo URL, or null when the brand has no logo yet.
  final String? logoUrl;
  final int carsCount;
  final String tagline;

  const Brand({
    required this.name,
    this.logoUrl,
    required this.carsCount,
    required this.tagline,
  });
}
