import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';

Future<Map<String, dynamic>> testCryptoGenerateRandomKey({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final keyWithDefaultLength = await Crypto.generateRandomKey();

  final keyWith128BitLength = await Crypto.generateRandomKey(keyLength: 128);

  // ignore: avoid_redundant_argument_values
  final keyWith256BitLength = await Crypto.generateRandomKey(keyLength: 256);

  return {
    'keyWithDefaultLength': keyWithDefaultLength,
    'keyWith128BitLength': keyWith128BitLength,
    'keyWith256BitLength': keyWith256BitLength,
  };
}
