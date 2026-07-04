import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/phone_login_provider.dart';

/// Required consent checkbox shown under the Continue button on the phone-login
/// screen: a checkbox plus "I agree to the Terms & Conditions and Privacy
/// Policy", with the two document names tappable. Continue stays disabled until
/// the box is ticked (see [PhoneLoginProvider.isButtonEnabled]). Tapping a link
/// opens the hosted document in the in-app browser via the `/legal/*` routes.
///
/// The sentence is assembled from a localized template containing `{terms}` and
/// `{privacy}` tokens, so each locale controls word order and placement.
class PhoneLoginConsent extends StatefulWidget {
  final bool isDark;
  const PhoneLoginConsent({super.key, required this.isDark});

  @override
  State<PhoneLoginConsent> createState() => _PhoneLoginConsentState();
}

class _PhoneLoginConsentState extends State<PhoneLoginConsent> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () => context.push('/legal/terms');
    _privacyTap = TapGestureRecognizer()..onTap = () => context.push('/legal/privacy');
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneLoginProvider>();
    final accepted = provider.acceptedTerms;

    final base = TextStyle(
      fontSize: 12.r,
      height: 1.5,
      color: widget.isDark ? Colors.white70 : const Color(0xFF757575),
    );
    final link = base.copyWith(color: const Color(0xFF677EF0), fontWeight: FontWeight.w600);

    final template = 'legal_consent'.tr();
    final termsLabel = 'legal_consent_terms'.tr();
    final privacyLabel = 'legal_consent_privacy'.tr();

    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\{(terms|privacy)\}');
    var last = 0;
    for (final m in pattern.allMatches(template)) {
      if (m.start > last) spans.add(TextSpan(text: template.substring(last, m.start)));
      if (m.group(1) == 'terms') {
        spans.add(TextSpan(text: termsLabel, style: link, recognizer: _termsTap));
      } else {
        spans.add(TextSpan(text: privacyLabel, style: link, recognizer: _privacyTap));
      }
      last = m.end;
    }
    if (last < template.length) spans.add(TextSpan(text: template.substring(last)));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24.r,
          height: 24.r,
          child: Checkbox(
            value: accepted,
            onChanged: (v) => context.read<PhoneLoginProvider>().setAcceptedTerms(v ?? false),
            activeColor: const Color(0xFF677EF0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side: BorderSide(
              color: widget.isDark ? Colors.white38 : const Color(0xFFBDBDBD),
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 12.r),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Tapping the sentence body (outside the links) toggles the box too.
            onTap: () => context.read<PhoneLoginProvider>().setAcceptedTerms(!accepted),
            child: Text.rich(TextSpan(style: base, children: spans)),
          ),
        ),
      ],
    );
  }
}
