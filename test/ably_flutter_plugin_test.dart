import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final channel =
      MethodChannel('io.ably.flutter.plugin', StandardMethodCodec(Codec()));

  TestWidgetsFlutterBinding.ensureInitialized();
  var counter = 0;

  //test constants
  const _platformVersion = '42';
  const _nativeLibraryVersion = '1.1.0';

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      switch (methodCall.method) {
        case PlatformMethod.resetAblyClients:
          return true;

        case PlatformMethod.getPlatformVersion:
          return _platformVersion;
        case PlatformMethod.getVersion:
          return _nativeLibraryVersion;

        case PlatformMethod.createRealtime:
          return ++counter;

        case PlatformMethod.publishRealtimeChannelMessage:
        case PlatformMethod.connectRealtime:
        default:
          return null;
      }
    });
    Platform(methodChannel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(PlatformMethod.getPlatformVersion, () async {
    expect(await platformVersion(), _platformVersion);
  });

  test(PlatformMethod.getVersion, () async {
    expect(await version(), _nativeLibraryVersion);
  });

  test(PlatformMethod.createRealtime, () async {
    const host = 'http://realtime.ably.io/';
    final o = ClientOptions(
      realtimeHost: host,
    );
    final realtime = Realtime(options: o);
    expect(await realtime.handle, counter);
    expect(realtime.options.realtimeHost, host);
  });

  test('createRealtimeWithToken', () async {
    const key = 'TEST-KEY';
    final realtime = Realtime.fromKey(key);
    expect(await realtime.handle, counter);
    expect(realtime.options.tokenDetails!.token, key);
  });

  test('createRealtimeWithKey', () async {
    const key = 'TEST:KEY';
    final realtime = Realtime.fromKey(key);
    expect(await realtime.handle, counter);
    expect(realtime.options.key, key);
  });

  test('publishMessage', () async {
    final realtime = Realtime.fromKey('TEST-KEY');
    await realtime.channels.get('test').publish(name: 'name', data: 'data');
    expect(1, 1);
  });
}
