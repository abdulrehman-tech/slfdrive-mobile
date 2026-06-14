# Secrets management

All secrets (API keys, publishable tokens, etc.) are stored in **gitignored**
files per platform. Only `.example` templates are committed.

```
.env                                     # dart-define source (web + Dart code)
android/secrets.properties               # Android manifest placeholders
ios/Flutter/Secrets.xcconfig             # iOS Info.plist / Swift runtime
```

On a fresh clone, copy each template and fill in real values:

```sh
cp .env.example .env
cp android/secrets.properties.example android/secrets.properties
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

## How each platform consumes the key

### Android

`android/app/build.gradle.kts` loads `android/secrets.properties` at Gradle
configure time and injects every entry as a `manifestPlaceholders` token. The
manifest then references them like:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

In CI, either commit an encrypted file + decrypt step, or export the same key
as an environment variable — the Gradle helper falls back to `System.getenv`.

### iOS

`ios/Flutter/Secrets.xcconfig` defines `MAPS_API_KEY = ...`. It is included
from `Debug.xcconfig` and `Release.xcconfig`. `Info.plist` exposes it:

```xml
<key>GMSApiKey</key>
<string>$(MAPS_API_KEY)</string>
```

`AppDelegate.swift` reads `Bundle.main.object(forInfoDictionaryKey: "GMSApiKey")`
at launch and passes it to `GMSServices.provideAPIKey(...)`.

### Web

The Google Maps JS SDK is **not** included in `web/index.html`. Instead,
`lib/src/core/secrets/maps_loader_web.dart` injects the `<script>` tag at
runtime using the compile-time define `GOOGLE_MAPS_API_KEY`.

Run/build web with:

```sh
flutter run  -d chrome   --dart-define-from-file=.env
flutter build web        --dart-define-from-file=.env
```

### Dart code (all platforms)

Any Dart-side use of a secret goes through `AppSecrets` in
`lib/src/core/secrets/app_secrets.dart`, which reads compile-time defines
supplied via `--dart-define-from-file=.env`.

### Places API (`PLACES_API_KEY`)

The location-picker search bar calls the **Places API (New)** over plain HTTPS
from Dart (`lib/src/core/services/places_service.dart`), reading
`AppSecrets.placesApiKey`. This is a **separate** key from the Maps SDK keys —
it must NOT carry an HTTP-referrer or Android/iOS application restriction:

- REST requests send an empty referer and no app signature, so a referrer- or
  app-restricted key returns `403 API_KEY_HTTP_REFERRER_BLOCKED` /
  `API_KEY_ANDROID_APP_BLOCKED`.
- The native Maps SDK keys in `secrets.properties` / `Secrets.xcconfig` are
  **not** usable here — Dart cannot read them, and their restrictions block REST.

Create a dedicated key, set **Application restrictions = None** and
**API restrictions = Places API (New)** only, then put it in `.env`:

```
PLACES_API_KEY=AIza...   # leave blank to fall back to GOOGLE_MAPS_API_KEY
```

Because it has no app restriction, cap abuse with a Cloud Console **quota
limit** on the Places API. The key is supplied via the same
`--dart-define-from-file=.env`, so a device run that needs Places must pass it:

```sh
flutter run --dart-define-from-file=.env
```

Validate a key the way the app calls it (no referer):

```sh
curl -s -X POST "https://places.googleapis.com/v1/places:autocomplete" \
  -H "Content-Type: application/json" -H "X-Goog-Api-Key: $PLACES_API_KEY" \
  -d '{"input":"Muscat"}'
```

## Recommended practice

1. **Restrict keys in Google Cloud** — bundle id / SHA-1 (Android), bundle id
   (iOS), HTTP referrer (web). A leaked but restricted key is near-useless.
2. **Separate keys per platform** when possible (Android key, iOS key, web
   key). Each can be restricted to its own bundle/referrer. The Places REST key
   (`PLACES_API_KEY`) is a fourth, app-restriction-free key — limit it by API +
   quota instead (see above).
3. **Never commit real values** — the `.gitignore` is already set up; just
   don't disable it.
4. **CI** — store secrets as masked env vars and write them into
   `secrets.properties` / `Secrets.xcconfig` / `.env` as a pre-build step.
