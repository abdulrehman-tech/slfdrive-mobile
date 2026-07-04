/// Single source of truth for legal / company identity used across the app
/// (login consent, Terms & Privacy screens) and referenced by the store
/// submission forms and the hosted policy pages under `docs/legal/`.
///
/// ⚠️ Fill these in before the first store submission. The same values must be
/// mirrored into `docs/legal/privacy-policy.html` and `terms-of-service.html`
/// (the copies you host publicly) — Apple and Google both require a reachable
/// HTTPS privacy-policy URL.
class LegalConstants {
  LegalConstants._();

  /// Public-facing product name.
  static const String appName = 'SLF Drive';

  /// Registered legal entity that operates the app. Shown as
  /// `SLF Drive (operated by companyLegalName)`.
  static const String companyLegalName = '[COMPANY_LEGAL_NAME]';

  /// Registered business address (used in the policy footer).
  static const String companyAddress = '[COMPANY_ADDRESS]';

  /// Jurisdiction whose laws govern the Terms.
  static const String governingLaw = 'the Sultanate of Oman';

  /// General support / contact inbox.
  static const String supportEmail = '[SUPPORT_EMAIL]';

  /// Privacy / data-request inbox (may equal supportEmail).
  static const String privacyEmail = '[PRIVACY_EMAIL]';

  /// Effective / last-updated date printed on the documents.
  static const String effectiveDate = '[EFFECTIVE_DATE]';

  /// Public HTTPS URLs where the policies are hosted. These are opened in an
  /// in-app browser from the login consent line and the Terms/Privacy tiles,
  /// and are the exact URLs you enter in the App Store / Play Console listings.
  ///
  /// ⚠️ Replace with the real hosted URLs before submission — the stores reject
  /// placeholder or unreachable links. Ready-to-host content lives in
  /// `docs/legal/`.
  static const String termsUrl = 'https://example.com/slfdrive/terms';
  static const String privacyUrl = 'https://example.com/slfdrive/privacy';
}
