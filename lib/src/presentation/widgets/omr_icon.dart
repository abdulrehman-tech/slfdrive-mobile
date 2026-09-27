import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Width / height of the Omani Rial glyph. The SVG viewBox is cropped to the
/// glyph itself (10.03 17.56 721.31 379.94), so the drawing's edges ARE the
/// glyph's edges: its foot sits exactly on a text baseline and its top at digit height.
const double _kOmrAspect = 721.31 / 379.94;

/// Height of a flat digit (1, 4, 7) as a fraction of the font size, measured
/// from the bundled fonts. The symbol is drawn at exactly this height so it
/// matches the digits beside it. Tajawal is used for Arabic and Urdu (see
/// `MyApp._getFontFamily`), Open Sans for everything else.
const double _kOpenSansDigitHeight = 0.714;
const double _kTajawalDigitHeight = 0.633;

double _digitHeightFactor(BuildContext context) {
  final lang = Localizations.maybeLocaleOf(context)?.languageCode;
  return (lang == 'ar' || lang == 'ur') ? _kTajawalDigitHeight : _kOpenSansDigitHeight;
}

/// Omani Rial currency symbol — the single source of the currency mark in the
/// app. Use [OmrAmount] for "symbol + number" and [omrSpan] inside text; both
/// put the symbol's foot on the digits' baseline.
///
/// [size] is the font size of the adjacent amount; the symbol is drawn at that
/// font's digit height.
class OmrIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const OmrIcon({super.key, this.size = 14, this.color});

  @override
  Widget build(BuildContext context) {
    final height = size * _digitHeightFactor(context);
    final width = height * _kOmrAspect;
    // Default to the surrounding text colour so the symbol always matches the
    // number it annotates; fall back to the themed black/white artwork.
    final effectiveColor = color ?? DefaultTextStyle.of(context).style.color;

    if (effectiveColor != null) {
      return SvgPicture.asset(
        'assets/icons/omr_black.svg',
        width: width,
        height: height,
        colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      isDark ? 'assets/icons/omr_white.svg' : 'assets/icons/omr_black.svg',
      width: width,
      height: height,
    );
  }
}

/// "﷼ 12.50" — the currency symbol followed by [text] (an already formatted
/// amount, optionally with a unit such as "/day"). The row follows the ambient
/// direction: the symbol leads the number in reading order in every locale
/// (left of it in LTR, right of it in RTL), matching the rest of the app.
class OmrAmount extends StatelessWidget {
  final String text;
  final TextStyle style;

  /// Symbol size; defaults to the text's font size.
  final double? iconSize;

  /// Symbol colour when it should differ from the text (defaults to style.color).
  final Color? iconColor;
  final double gap;

  const OmrAmount(this.text, {super.key, required this.style, this.iconSize, this.iconColor, this.gap = 3});

  /// Formats [amount] with [decimals] places, then appends [suffix].
  factory OmrAmount.value(
    double amount, {
    Key? key,
    required TextStyle style,
    int decimals = 2,
    String suffix = '',
    double? iconSize,
    Color? iconColor,
    double gap = 3,
  }) => OmrAmount(
    '${amount.toStringAsFixed(decimals)}$suffix',
    key: key,
    style: style,
    iconSize: iconSize,
    iconColor: iconColor,
    gap: gap,
  );

  @override
  Widget build(BuildContext context) {
    // One paragraph with the symbol as a baseline placeholder: the text engine
    // puts the placeholder's bottom edge exactly on the digits' baseline. (A
    // baseline Row can't do this — an SVG has no baseline, so the Row pins it
    // to the top of the line box and it floats above the digits.)
    final iconStyle = iconColor == null && iconSize == null
        ? style
        : style.copyWith(color: iconColor ?? style.color, fontSize: iconSize ?? style.fontSize);
    return Text.rich(
      TextSpan(
        style: style,
        children: [omrSpan(iconStyle, gap: gap), TextSpan(text: text)],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// The currency symbol as an inline span, for amounts inside a sentence
/// (`Text.rich(TextSpan(children: [..., omrSpan(style), TextSpan(text: '5.00')]))`).
InlineSpan omrSpan(TextStyle style, {double gap = 3}) => WidgetSpan(
  // aboveBaseline: the placeholder's bottom edge sits on the text baseline,
  // like the digits' feet. (`baseline` would need a baseline on the child; an
  // SVG has none, so it would drop to the line's descent.)
  alignment: PlaceholderAlignment.aboveBaseline,
  baseline: TextBaseline.alphabetic,
  child: Padding(
    padding: EdgeInsetsDirectional.only(end: gap),
    child: OmrIcon(size: style.fontSize ?? 14, color: style.color),
  ),
);
