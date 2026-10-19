import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';

Future<Map<String, dynamic>> testRealtimeTime({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final realtime = createClient(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );

  final realtimeTime = await realtime.time();

  return {
    'handle': await realtime.handle,
    'time': realtimeTime.toIso8601String(),
  };
}
