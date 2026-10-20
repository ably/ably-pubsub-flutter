import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_method_call_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMethodCallManager manager;
  late RealtimeChannels channels;

  setUp(() {
    manager = MockMethodCallManager();
    final realtime = createClient(options: ClientOptions(key: 'TEST-KEY'));
    channels = realtime.channels;
  });

  tearDown(() {
    manager.reset();
  });

  group('realtime#channels', () {
    test('creates channel with #get', () {
      final channel = channels.get('channel-1');
      expect(channel.name, 'channel-1');
    });

    test('checks if channel exist with #exists', () {
      var hasChannel = channels.exists('channel-2');
      expect(hasChannel, false);

      final channel = channels.get('channel-2');
      expect(channel.name, 'channel-2');

      hasChannel = channels.exists('channel-2');
      expect(hasChannel, true);
    });

    test('creates/returns channel with list accessor #[]', () {
      final channel2 = channels.get('channel-2');
      final channel2WithSyntacticSugar = channels['channel-2'];
      expect(channel2WithSyntacticSugar, channel2);

      final channel3 = channels['channel-3'];
      expect(channel3.name, 'channel-3');
    });

    test('iterates over created channels', () {
      channels
        ..get('channel-1')
        ..get('channel-2')
        ..get('channel-3')
        ..get('channel-33');

      expect(
        channels.map((e) => e.name).toList(),
        orderedEquals(const [
          'channel-1',
          'channel-2',
          'channel-3',
          'channel-33',
        ]),
      );

      expect(
        channels.where((e) => e.name.endsWith('3')).map((e) => e.name).toList(),
        orderedEquals(const [
          'channel-3',
          'channel-33',
        ]),
      );
    });

    test('allows querying length', () {
      channels
        ..get('channel-1')
        ..get('channel-2');

      expect(channels.length, 2);

      channels
        ..get('channel-3')
        ..get('channel-33');

      expect(channels.length, 4);
    });

    group('#release', () {
      test(
          '(RTS4d) Releasing a channel the platform SDK releases'
          ' removes it from the collection', () async {
        channels
          ..get('channel-1')
          ..get('channel-2');
        expect(channels.length, 2);
        await channels.release('channel-1');
        expect(channels.length, 1);
        expect(channels.exists('channel-1'), false);
      });

      test(
          '(RTS4c) Calling release() with a channel name'
          ' that does not correspond to an extant channel'
          ' must return without error', () async {
        channels
          ..get('channel-1')
          ..get('channel-2');
        expect(channels.length, 2);
        await channels.release('channel-3');
        expect(channels.length, 2);
        expect(channels.exists('channel-1'), true);
        expect(channels.exists('channel-2'), true);
      });

      test(
          '(RTS4e) If the platform SDK fails to release the channel,'
          ' release() completes with its error and the channel is not'
          ' removed', () async {
        final channel = channels.get('channel-1');
        manager.releaseRealtimeChannelError = PlatformException(
          code: '90011',
          message: 'Can only release a channel in a state where there is no'
              ' possibility of further updates from the server being'
              ' received (initialized, detached, or failed).'
              ' The current state is attached',
          details: ErrorInfo(code: 90011, statusCode: 400),
        );

        await expectLater(
          channels.release('channel-1'),
          throwsA(
            isA<AblyException>()
                .having((e) => e.errorInfo?.code, 'errorInfo.code', 90011)
                .having((e) => e.errorInfo?.statusCode, 'errorInfo.statusCode',
                    400),
          ),
        );
        expect(channels.exists('channel-1'), true);
        expect(channels.get('channel-1'), same(channel));
      });
    });
  });
}
