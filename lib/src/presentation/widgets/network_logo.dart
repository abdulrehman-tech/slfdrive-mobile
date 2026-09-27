import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/services/company_directory.dart';

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
    final letter = _Letter(name: name, style: letterStyle);
    if (url == null || url!.isEmpty) return letter;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, _) => letter,
      errorWidget: (_, _, _) => letter,
    );
  }
}

class _Letter extends StatelessWidget {
  final String name;
  final TextStyle style;
  const _Letter({required this.name, required this.style});

  @override
  Widget build(BuildContext context) {
    final t = name.trim();
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(t.isEmpty ? '?' : t.characters.first.toUpperCase(), style: style),
      ),
    );
  }
}

/// Logo on a rounded plate. With an image the plate is white (logos are drawn
/// for light backgrounds): square images fill it, wordmarks and photos are
/// contained with a margin so nothing is cropped. Without one (or when the
/// file can't be decoded, e.g. AVIF) the plate shows the initial on the brand
/// gradient.
class LogoPlate extends StatelessWidget {
  final String? url;
  final String name;
  final double size;

  /// Corner radius; `null` makes the plate a circle.
  final double? radius;
  final bool shadow;

  /// Hairline around a white plate so it doesn't melt into light cards.
  final bool outline;

  const LogoPlate({
    super.key,
    required this.url,
    required this.name,
    required this.size,
    this.radius,
    this.shadow = false,
    this.outline = true,
  });

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
  );

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    final shape = radius == null ? BoxShape.circle : BoxShape.rectangle;
    final r = radius == null ? null : BorderRadius.circular(radius!);
    final letter = _Letter(
      name: name,
      style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
    );
    Widget plate(Widget child, {required bool white}) => Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: r,
            color: white ? Colors.white : null,
            gradient: white ? null : _gradient,
            border: white && outline ? Border.all(color: Colors.black.withValues(alpha: 0.08), width: 0.8) : null,
            boxShadow: shadow
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: size * 0.2, offset: Offset(0, size * 0.06))]
                : null,
          ),
          child: child,
        );

    if (!hasUrl) return plate(letter, white: false);
    return _AdaptiveLogo(
      url: url!,
      inset: size * 0.12,
      loaded: (image) => plate(image, white: true),
      fallback: plate(letter, white: false),
    );
  }
}

/// Resolves the image once to learn its aspect ratio, then picks cover
/// (squarish) or contain-with-inset (wide/tall) before painting.
class _AdaptiveLogo extends StatefulWidget {
  final String url;
  final double inset;
  final Widget Function(Widget image) loaded;
  final Widget fallback;

  const _AdaptiveLogo({required this.url, required this.inset, required this.loaded, required this.fallback});

  @override
  State<_AdaptiveLogo> createState() => _AdaptiveLogoState();
}

class _AdaptiveLogoState extends State<_AdaptiveLogo> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double? _aspect;
  bool _failed = false;

  CachedNetworkImageProvider get _provider => CachedNetworkImageProvider(widget.url);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_AdaptiveLogo old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _aspect = null;
      _failed = false;
      _resolve();
    }
  }

  void _resolve() {
    final stream = _provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stop();
    _listener = ImageStreamListener(
      (info, _) {
        final a = info.image.width / info.image.height;
        info.dispose();
        if (mounted && a != _aspect) setState(() => _aspect = a);
      },
      onError: (_, _) {
        if (mounted) setState(() => _failed = true);
      },
    );
    _stream = stream..addListener(_listener!);
  }

  void _stop() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspect;
    if (_failed || aspect == null) return widget.fallback;
    final squarish = aspect > 0.8 && aspect < 1.25;
    final image = Image(image: _provider, fit: squarish ? BoxFit.cover : BoxFit.contain, gaplessPlayback: true);
    return widget.loaded(squarish ? image : Padding(padding: EdgeInsets.all(widget.inset), child: image));
  }
}

/// A rental company's logo, looked up by id in [CompanyDirectory] (vehicle,
/// driver and booking payloads carry no logo). [logoUrl] overrides the lookup
/// when the caller already has it (the profile page).
class CompanyAvatar extends StatelessWidget {
  final int? companyId;
  final String name;
  final double size;
  final double? radius;
  final bool shadow;
  final String? logoUrl;

  const CompanyAvatar({
    super.key,
    required this.companyId,
    required this.name,
    required this.size,
    this.radius,
    this.shadow = false,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final directory = getIt.isRegistered<CompanyDirectory>() ? getIt<CompanyDirectory>() : null;
    if (directory == null || logoUrl != null) {
      return LogoPlate(url: logoUrl, name: name, size: size, radius: radius, shadow: shadow);
    }
    directory.ensureLoaded();
    return ListenableBuilder(
      listenable: directory,
      builder: (_, _) =>
          LogoPlate(url: directory.logoFor(companyId), name: name, size: size, radius: radius, shadow: shadow),
    );
  }
}
