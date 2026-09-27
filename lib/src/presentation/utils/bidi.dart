import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Left-to-right isolate (U+2066) and pop-directional-isolate (U+2069), built
/// from code points so the source stays free of invisible bidi characters.
final String _lri = String.fromCharCode(0x2066);
final String _pdi = String.fromCharCode(0x2069);

/// Wraps [s] in a left-to-right isolate so numbers like "+968 9455 7866" keep
/// their order inside right-to-left (Arabic/Urdu) text. Without it the bidi
/// algorithm moves the leading "+" to the end.
String ltr(String s) => s.isEmpty ? s : '$_lri$s$_pdi';

/// True when the ambient layout is right-to-left (Arabic, Urdu). Uses
/// `dart:ui`'s [ui.TextDirection] because easy_localization re-exports intl's
/// unrelated `TextDirection`.
bool isRtl(BuildContext context) => Directionality.of(context) == ui.TextDirection.rtl;
