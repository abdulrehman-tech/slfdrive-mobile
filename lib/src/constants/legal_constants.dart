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

  /// Public marketing/legal site host.
  static const String _siteBase = 'https://slf-drives.com';

  /// The hosted policy pages exist in English and Arabic only; any other app
  /// locale falls back to the English page.
  static String _pathLang(String languageCode) => languageCode == 'ar' ? 'ar' : 'en';

  /// Public HTTPS URLs where the policies are hosted, localized to the app's
  /// current language. Opened in an in-app browser from the login consent line
  /// and the Terms/Privacy tiles, and mirror the App Store / Play Console links.
  static String termsUrl(String languageCode) => '$_siteBase/${_pathLang(languageCode)}/terms';
  static String privacyUrl(String languageCode) => '$_siteBase/${_pathLang(languageCode)}/privacy';
}
