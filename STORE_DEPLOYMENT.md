# SLF Drive — App Store & Play Store Deployment Guide

End-to-end procedure to ship SLF Drive to the **Apple App Store** and **Google
Play Store** from fresh (no apps created yet). Do the sections in order.

- **Package / Bundle ID:** `com.gmq.slfdrive` (Android `applicationId` + iOS bundle id — **immutable after first submission**)
- **Display name:** `SLF Drive`
- **iOS Apple Developer account:** Mohamed Al Mahri — Team ID `G6ALSFTBXG` (already set in the Xcode project)
- **Current version:** `1.0.0+1` (`versionName` `1.0.0`, `versionCode`/build `1`) — set in `pubspec.yaml`

---

## 0. What is already done at the code level ✅

- Display name set to **SLF Drive** (`AndroidManifest.xml` label, iOS `CFBundleDisplayName`).
- Launcher icons regenerated for **all Android densities + adaptive icon + iOS** from `assets/icon/app_icon.png` (`flutter_launcher_icons` configured in `pubspec.yaml`).
- Native launch splash generated for Android (incl. Android 12+) and iOS (`flutter_native_splash` configured).
- **Terms & Conditions + Privacy Policy**:
  - Shown as a consent line on the phone-login screen: *"By continuing, you agree to our Terms & Conditions and Privacy Policy"* — both names tappable (mobile + desktop layouts).
  - Also linked from the Profile → Support section and the app drawer.
  - Open **inside the app** in an in-app WebView (`LegalDocumentScreen`) — never the external browser.
  - Localized in all 7 locales.
  - Ready-to-host document copies in [`docs/legal/`](docs/legal/).
- Permissions already declared with purpose strings: foreground location, photo library (iOS). No background location (keeps review simple).

## 0.1 What YOU must fill in before submitting ⚠️

1. **`lib/src/constants/legal_constants.dart`** — replace every `[BRACKET]` placeholder:
   - `companyLegalName`, `companyAddress`, `supportEmail`, `privacyEmail`, `effectiveDate`
   - `termsUrl`, `privacyUrl` → the **live HTTPS URLs** where you host the policies.
2. **Host the two policies** at those URLs (use `docs/legal/*.html`, replacing the same `[BRACKET]` tokens, or your own pages). Both stores **require a reachable privacy-policy URL** and reject placeholders/404s.
3. Confirm the launcher master art `assets/icon/app_icon.png` is the final 1024×1024 icon (currently seeded from the existing iOS icon). If you swap it, rerun the two generate commands below.

Regenerate icon/splash after any art change:
```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 1. Prerequisites (both platforms)

- Flutter 3.38+ installed; `flutter doctor` clean.
- Secrets present (see `SECRETS.md`): `.env`, `android/secrets.properties`, `ios/Flutter/Secrets.xcconfig` with the real `GOOGLE_MAPS_API_KEY` / `MAPS_API_KEY`.
- A **restricted, production** Google Maps API key (restrict to the iOS bundle id and Android package + SHA-1; enable Maps SDK for Android/iOS).
- Final store listing assets ready (see §4).
- Legal placeholders filled and policy URLs live (§0.1).

---

## 2. Google Play Store

### 2.1 Accounts & one-time setup
1. Create a **Google Play Developer account** at <https://play.google.com/console> ($25 one-time). For a company, choose an **Organization** account (needs D-U-N-S; verification can take days — start early).
2. Complete account **identity verification** (address, phone, and for orgs the D-U-N-S number).
3. Accept the Developer Distribution Agreement.

### 2.2 Release signing (upload keystore)
Play uses **Play App Signing**: you upload with an *upload key*; Google holds the *app signing key*.

**✅ Already created in this repo:**
- Upload keystore: `android/upload-keystore.jks` (gitignored) — RSA 2048, valid 10000 days, alias `upload`.
- `android/key.properties` (gitignored) — Gradle reads it and signs release builds automatically:
  ```properties
  storeFile=upload-keystore.jks
  storePassword=android
  keyAlias=upload
  keyPassword=android
  ```
  > ⚠️ Password is `android` (as requested — fine for setup/testing). **Change to a strong password + back up the `.jks` off-machine before you rely on it for production updates.** Losing this keystore blocks future updates unless you reset the upload key via Google.

**Fingerprints of the upload key** (add to Google Maps key restriction, Firebase, and any SMS/OTP provider):
- **SHA-1:** `58:DE:EB:32:13:5B:61:5B:79:54:61:E3:16:60:50:FE:05:2C:26:BE`
- **SHA-256:** `EA:97:91:6C:35:03:95:B0:D2:C0:E2:3A:78:A4:45:48:E5:52:CD:5B:9D:E6:CB:34:08:BB:46:94:5F:5B:6A:47`

Re-extract anytime:
```sh
keytool -list -v -keystore android/upload-keystore.jks -alias upload -storepass android | grep -i SHA
```
> After you upload the first build, Google's **Play App Signing** adds a second (app-signing) SHA-1/256 under Play Console → Setup → App signing. Add **that** one to your Maps/Firebase restrictions too — it's the cert end users actually run.

To regenerate the keystore from scratch (only if needed):
```sh
keytool -genkeypair -v -keystore android/upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=SLF Drive, OU=Mobile, O=SLF Drive, L=Muscat, ST=Muscat, C=OM"
```

### 2.3 Build the release bundle
Play requires an **App Bundle (.aab)**:
```sh
flutter clean
flutter pub get
flutter build appbundle --release --dart-define-from-file=.env
# output: build/app/outputs/bundle/release/app-release.aab
```
> `--dart-define-from-file=.env` is mandatory — it injects `GOOGLE_MAPS_API_KEY`.

Bump `version: 1.0.0+1` in `pubspec.yaml` for every upload (`+N` = `versionCode`, must strictly increase).

### 2.4 Create the app in Play Console
1. **Create app** → name `SLF Drive`, language, **App** (not game), **Free/Paid**.
2. **App content** (Policy section) — fill all:
   - **Privacy policy** → your live `privacyUrl`.
   - **Data safety** form — declare what SLF Drive collects/shares. For this app:
     - Personal info: **Name, Phone number**, (Email if collected).
     - **Location** (approximate + precise) — "App functionality"; collected, not shared, while in use.
     - **Photos** (profile picture) — "App functionality".
     - **Financial info**: payments handled by OmPay — declare per how the SDK/webview collects; you generally don't store card numbers.
     - Data encrypted in transit: **Yes**. Users can request deletion: **Yes** (provide the method).
   - **App access** — provide **demo login credentials / test phone + OTP** for reviewers (auth is phone-OTP; give a test number the backend will accept, or a review bypass).
   - **Content rating** questionnaire (IARC) → likely Everyone.
   - **Target audience** → 18+ (matches the Terms). Not directed to children.
   - **Ads** → declare whether the app shows ads (currently none).
   - **Government apps / financial features / data types** as applicable.
3. **Store listing**: short (80 chars) + full (4000) description, app icon (512×512), feature graphic (1024×500), phone screenshots (min 2; see §4), category = *Maps & Navigation* or *Travel & Local*, contact email, privacy URL.

### 2.5 Test tracks → production
1. Upload the `.aab` to **Internal testing** first (fastest; up to 100 testers by email list). Verify install, maps, OTP login, booking, OmPay payment on a real device.
2. Move to **Closed** → **Open** testing if you want wider QA (new personal-developer accounts may need a testing period before production — check current Play policy).
3. **Production** → create release → upload `.aab` → add release notes → **roll out**. First review typically hours–days.

---

## 3. Apple App Store

### 3.1 Accounts & one-time setup
1. Enroll in the **Apple Developer Program** at <https://developer.apple.com/programs/> ($99/yr). For a company use an **Organization** enrollment (needs a D-U-N-S number + authority to sign).
2. In **App Store Connect** (<https://appstoreconnect.apple.com>) accept agreements; complete **Agreements, Tax, and Banking** (required even for a free app).

### 3.2 Register the App ID & bundle
1. The bundle id `com.gmq.slfdrive` must exist under your team. Easiest: open `ios/Runner.xcworkspace` in Xcode → Signing & Capabilities → Team `G6ALSFTBXG` → let Xcode **auto-manage signing** (registers the App ID + provisioning profile). Ensure capabilities match what the app uses (no push/associated-domains needed unless you add them).
2. Verify the Maps key in `ios/Flutter/Secrets.xcconfig` is a production key restricted to this bundle id.

### 3.3 Version & build numbers
- `MARKETING_VERSION` (`CFBundleShortVersionString`) and build (`CFBundleVersion`) come from `pubspec.yaml` (`1.0.0+1`). Each **upload** to App Store Connect needs a **unique build number** — bump `+N`.

### 3.4 Archive & upload
```sh
flutter build ipa --release --dart-define-from-file=.env
```
This produces `build/ios/archive/Runner.xcarchive` and (if signing is configured) an `.ipa` under `build/ios/ipa/`. Then either:
- Open **Xcode → Organizer**, select the archive, **Distribute App → App Store Connect → Upload**, or
- Use **Transporter** (Mac App Store) to upload the `.ipa`, or
- `xcrun altool` / `xcrun notarytool` from CI.

> Build on macOS with Xcode. If auto-signing fails, create an **App Store** distribution certificate + provisioning profile for `com.gmq.slfdrive` in the Developer portal and set manual signing.

### 3.5 Create the app record in App Store Connect
1. **My Apps → +** → **New App**: platform iOS, name `SLF Drive`, primary language, bundle id `com.gmq.slfdrive`, SKU (any unique string).
2. **App Privacy** (nutrition labels) — mirror the Play Data safety:
   - **Contact Info**: Name, Phone Number, (Email).
   - **Location**: Precise/Coarse — *App Functionality*.
   - **User Content**: Photos (profile).
   - **Financial Info** / **Purchases** as handled by OmPay.
   - Link the **Privacy Policy URL** (`privacyUrl`).
3. **Export compliance**: the app uses HTTPS/standard crypto only → typically "uses encryption" = Yes, "exempt" = Yes (standard). Set `ITSAppUsesNonExemptEncryption=false` in Info.plist to skip the per-build prompt if that's accurate for your usage.
4. **Age rating** questionnaire → 17+/18+ consistent with the Terms.
5. **App Review Information**: provide a **test phone number + OTP** (or reviewer bypass) since sign-in is phone-OTP — reviewers **must** be able to log in, or the build is rejected. Add notes explaining the OTP flow and OmPay test payment.
6. **Store listing**: description, keywords, support URL, marketing URL (optional), screenshots (§4), and the 1024×1024 icon (no alpha — already handled by `remove_alpha_ios`).

### 3.6 TestFlight → submit
1. After upload, the build appears in **TestFlight** (may show "Processing" for a while). Add internal testers → install on device → verify maps, OTP login, booking, OmPay.
2. Attach the build to the App Store version → **Add for Review** → **Submit**. Apple review is typically 24–48h.

---

## 4. Store listing assets (prepare once, use on both)

| Asset | Apple | Google |
|---|---|---|
| App icon | 1024×1024 PNG, no alpha | 512×512 PNG |
| Feature graphic | — | 1024×500 PNG |
| Phone screenshots | 6.7" (1290×2796) + 6.5"; ≥1 | 1080×1920+ ; 2–8 |
| Tablet screenshots | 12.9" iPad (if iPad enabled) | 7"/10" (optional) |
| Description | 4000 chars + subtitle/keywords | 80-char short + 4000 full |
| Privacy Policy URL | required | required |
| Support URL/email | required | required |

Screenshot tip: capture on real devices/simulators from key screens (home, car detail, booking, driver, profile). Use `flutter run --release` per device size.

---

## 5. Pre-submission checklist

- [ ] `legal_constants.dart` placeholders filled; `termsUrl` + `privacyUrl` **live over HTTPS**.
- [ ] Terms/Privacy open in-app and load correctly on device.
- [ ] `android/key.properties` present; `.aab` signed with the **upload key** (not debug).
- [ ] Maps render on a **release** build on real Android + iOS devices (key restrictions correct).
- [ ] OTP login works on release builds; a **reviewer test number** is provided to both stores.
- [ ] OmPay checkout completes on device (self-signed host ATS/allowlist verified).
- [ ] `version` bumped; build numbers unique per upload.
- [ ] Data safety (Play) and App Privacy (Apple) match the actual `NSLocation…`, photo, and payment usage.
- [ ] `flutter analyze` clean; smoke-tested all 7 locales incl. RTL (ar/ur).
- [ ] App display name shows **SLF Drive** on the device home screen.

---

## 6. Handy commands

```sh
# Android
flutter build appbundle --release --dart-define-from-file=.env      # Play upload (.aab)
flutter build apk --release --dart-define-from-file=.env            # sideload test

# iOS (macOS)
flutter build ipa --release --dart-define-from-file=.env            # App Store upload

# Regenerate branding after art changes
dart run flutter_launcher_icons
dart run flutter_native_splash:create

flutter analyze
```
