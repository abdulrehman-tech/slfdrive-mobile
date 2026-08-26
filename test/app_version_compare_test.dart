import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/utils/app_version_compare.dart';

void main() {
  bool outdated(String? latest, int? latestBuild, {String current = '1.0.1', int build = 15}) =>
      isAppOutdated(
        currentVersion: current,
        currentBuild: build,
        latestVersion: latest,
        latestBuild: latestBuild,
      );

  group('isAppOutdated', () {
    test('placeholder "1" row is not newer than 1.0.1', () => expect(outdated('1', 1), isFalse));
    test('"1" equals "1.0.0"', () => expect(outdated('1', 1, current: '1.0.0', build: 1), isFalse));
    test('higher patch is outdated', () => expect(outdated('1.0.2', 1), isTrue));
    test('higher minor is outdated', () => expect(outdated('1.1.0', 1), isTrue));
    test('numeric, not lexical: 1.0.10 > 1.0.9', () =>
        expect(outdated('1.0.10', 1, current: '1.0.9'), isTrue));
    test('same version, higher build is outdated', () => expect(outdated('1.0.1', 16), isTrue));
    test('same version, same build is current', () => expect(outdated('1.0.1', 15), isFalse));
    test('same version, null build is current', () => expect(outdated('1.0.1', null), isFalse));
    test('older version with higher build is current', () =>
        expect(outdated('1.0.0', 99), isFalse));
    test('null latest is never outdated', () => expect(outdated(null, 99), isFalse));
    test('garbage latest is never outdated', () => expect(outdated('abc', 99), isFalse));
    test('pubspec-style "+build" suffix is ignored', () =>
        expect(outdated('1.0.1+20', 15), isFalse));
  });
}
