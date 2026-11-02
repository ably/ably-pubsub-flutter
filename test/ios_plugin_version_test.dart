import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The iOS plugin reports its version to Ably in the `ably-flutter` agent.
/// Unlike the podspec it replaced, its Swift package cannot read
/// `pubspec.yaml`, so the version is duplicated in a header that has to be
/// bumped alongside it.
void main() {
  test('iOS plugin version matches pubspec.yaml', () {
    final pubspecVersion = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1);
    final iosVersion = RegExp('FLUTTER_PACKAGE_PLUGIN_VERSION @"([^"]+)"')
        .firstMatch(
          File(
            'ios/ably_pubsub_device_flutter/Sources/ably_pubsub_device_flutter/'
            'codec/AblyFlutterVersion.h',
          ).readAsStringSync(),
        )!
        .group(1);

    expect(iosVersion, pubspecVersion);
  });
}
