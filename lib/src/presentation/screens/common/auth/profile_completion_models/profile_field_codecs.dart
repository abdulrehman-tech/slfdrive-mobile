/// Shared encode/decode helpers between the profile **completion** and **edit**
/// forms, so the two flows never diverge on gender codes or language CSV.
///
/// Display labels come from [kGenderOptions] / [kLanguageOptions]; the backend
/// stores single-letter gender codes (`M`/`F`/`O`) and a comma-separated list of
/// language codes (`en,ar,hi`).
class ProfileFieldCodecs {
  ProfileFieldCodecs._();

  /// Display label → backend gender code.
  static const Map<String, String> genderCodes = {
    'Male': 'M',
    'Female': 'F',
    'Other': 'O',
    'Prefer not to say': 'O',
  };

  /// Display label → backend language code.
  static const Map<String, String> languageCodes = {
    'English': 'en',
    'Arabic': 'ar',
    'Hindi': 'hi',
    'Urdu': 'ur',
    'Malayalam': 'ml',
    'Tamil': 'ta',
    'Tagalog': 'tl',
    'Bengali': 'bn',
    'French': 'fr',
  };

  /// Backend gender code (`M`/`F`/`O`) for [label], or '' when unknown.
  static String encodeGender(String? label) => genderCodes[label] ?? '';

  /// Display label for a stored gender [code]; falls back to 'Other' for the
  /// shared `O` code and null when the code is empty/unknown.
  static String? decodeGender(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    switch (code.trim().toUpperCase()) {
      case 'M':
      case 'MALE':
      case '1':
        return 'Male';
      case 'F':
      case 'FEMALE':
      case '2':
        return 'Female';
      case 'O':
      case 'OTHER':
      case 'PREFER NOT TO SAY':
      case '3':
        return 'Other';
      default:
        return null;
    }
  }

  /// Comma-separated backend language codes for the selected display [labels].
  static String encodeLanguages(List<String> labels) =>
      labels.map((l) => languageCodes[l] ?? l.toLowerCase()).join(',');

  /// Display labels for a stored language [csv] (e.g. `en,ar`). Unknown codes
  /// are dropped.
  static List<String> decodeLanguages(String? csv) {
    if (csv == null || csv.trim().isEmpty) return <String>[];
    final reverse = {
      for (final e in languageCodes.entries) e.value: e.key,
    };
    return csv
        .split(',')
        .map((c) => c.trim().toLowerCase())
        .where((c) => c.isNotEmpty)
        .map((c) => reverse[c])
        .whereType<String>()
        .toList();
  }
}
