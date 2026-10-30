import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_method_call_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMethodCallManager manager;
  late PushChannel pushChannel;

  setUp(() {
    manager = MockMethodCallManager();
    final realtime = createClient(options: ClientOptions(key: 'TEST-KEY'));
    pushChannel = realtime.channels.get('channel').push;
  });

  tearDown(() {
    manager.reset();
  });

  group('PushChannel#listSubscriptions', () {
    for (final params in <Map<String, String>>[
      {},
      {'channel': 'channel'},
      {'deviceClientId': 'client'},
      {'deviceId': 'device', 'clientId': 'client'},
    ]) {
      test('rejects $params', () {
        expect(
          () => pushChannel.listSubscriptions(params),
          throwsA(isA<AblyException>()),
        );
      });
    }
  });
}
