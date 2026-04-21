import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'app_secrets.dart';

/// Dynamically injects the Google Maps JavaScript SDK using the API key from
/// `--dart-define=GOOGLE_MAPS_API_KEY=...`. Idempotent — subsequent calls are
/// no-ops. This keeps the key out of `web/index.html`.
Future<void> ensureGoogleMapsLoaded() async {
  const key = AppSecrets.googleMapsApiKey;
  if (key.isEmpty) {
    // ignore: avoid_print
    print('⚠️ slfdrive: GOOGLE_MAPS_API_KEY missing — pass '
        '--dart-define-from-file=.env to your flutter run/build command.');
    return;
  }

  final doc = web.document;
  if (doc.querySelector('script[data-slf-maps]') != null) return;

  final completer = Completer<void>();
  final script = doc.createElement('script') as web.HTMLScriptElement
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$key&libraries=places'
    ..async = true
    ..defer = true
    ..setAttribute('data-slf-maps', 'true');

  script.onload = ((web.Event _) => completer.complete()).toJS;
  script.onerror = ((web.Event _) => completer.completeError(
        StateError('Failed to load Google Maps SDK'),
      )).toJS;

  doc.head!.append(script);
  return completer.future;
}
