import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helpers to open external contact channels (WhatsApp / phone call / SMS).
///
/// All helpers:
///   - Strip whitespace, dashes and parens from the phone number.
///   - Keep the leading `+` if supplied (international format recommended).
///   - Return `true` when the launch succeeded, `false` otherwise.
class ContactLauncher {
  ContactLauncher._();

  static String _sanitize(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned;
  }

  /// Open WhatsApp chat with optional pre-filled [message].
  static Future<bool> openWhatsApp(String phone, {String? message}) async {
    final number = _sanitize(phone).replaceAll('+', '');
    final uri = Uri.parse(
      'https://wa.me/$number${message != null && message.isNotEmpty ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    return _launch(uri);
  }

  /// Start a phone call.
  static Future<bool> openPhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: _sanitize(phone));
    return _launch(uri);
  }

  /// Open default SMS composer with optional [body].
  static Future<bool> openSms(String phone, {String? body}) async {
    final uri = Uri(
      scheme: 'sms',
      path: _sanitize(phone),
      queryParameters: body != null && body.isNotEmpty ? {'body': body} : null,
    );
    return _launch(uri);
  }

  /// Open any email composer with optional [subject] / [body].
  static Future<bool> openEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      }.isEmpty
          ? null
          : {
              if (subject != null && subject.isNotEmpty) 'subject': subject,
              if (body != null && body.isNotEmpty) 'body': body,
            },
    );
    return _launch(uri);
  }

  static Future<bool> _launch(Uri uri) async {
    try {
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ContactLauncher failed to open $uri: $e');
      }
      return false;
    }
  }
}
