![Ably Pub/Sub Flutter Header](https://raw.githubusercontent.com/ably/ably-pubsub-flutter/main/images/flutter-github.png)

[![pub.dev: ably_pubsub_device_flutter](https://img.shields.io/pub/v/ably_pubsub_device_flutter?label=ably_pubsub_device_flutter)](https://pub.dev/packages/ably_pubsub_device_flutter)
[![License](https://badgen.net/github/license/ably/ably-pubsub-flutter)](https://github.com/ably/ably-pubsub-flutter/blob/main/LICENSE)

# Ably Pub/Sub Flutter SDK

The Flutter SDK for [Ably Pub/Sub](https://ably.com/docs/basics): publish and subscribe to
channels, and use message history, presence and push notifications, from Android and iOS apps.

## Overview

This SDK provides the device package only, for end-user apps. There is no server package; for
backends, use a server SDK such as [JavaScript](https://github.com/ably/ably-pubsub-js),
[Java](https://github.com/ably/ably-pubsub-java), [Go](https://github.com/ably/ably-pubsub-go),
[.NET](https://github.com/ably/ably-pubsub-dotnet), [Python](https://github.com/ably/ably-pubsub-python),
[PHP](https://github.com/ably/ably-pubsub-php) or [Ruby](https://github.com/ably/ably-pubsub-ruby).

| Package | Use it for | Entry point |
|---------|------------|-------------|
| [`ably_pubsub_device_flutter`](https://pub.dev/packages/ably_pubsub_device_flutter) | Applications on end-user devices | `createClient` |

## Requirements

Flutter 3.44 or later, with Dart 3.12 or later. Apps run on Android 7.0 (API level 24) or later
and iOS 15 or later, and iOS builds need Xcode 26 or later.

## Installation

```bash
flutter pub add ably_pubsub_device_flutter
```

### iOS setup

The plugin is a Swift package that needs iOS 15, but `flutter create` targets iOS 13. In Xcode, open
`ios/Runner.xcworkspace` and set **Runner > General > Minimum Deployments** to 15.0 or later.
Swift Package Manager is on by default from Flutter 3.44; if your app turns it off, see
[UPDATING.md](https://github.com/ably/ably-pubsub-flutter/blob/main/UPDATING.md#upgrading-from-v12x).

## Quick start

Authenticate a device with tokens issued by your own server, through `authUrl` or `authCallback`.
Never embed an API key in an app that runs on an end-user device.

```dart
import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart' as ably;
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = ably.createClient(
    options: ably.ClientOptions(
      authUrl: 'https://your-server.example.com/ably-auth',
      clientId: 'me',
    ),
  );

  // The client connects automatically. Subscribing attaches the channel.
  final channel = client.channels.get('test-channel');
  channel.subscribe().listen((ably.Message message) {
    print('Received: ${message.data}');
  });

  await channel.publish(name: 'test-event', data: 'hello world');
}
```

To get tokens from your own code instead of a URL, set `authCallback`. It can return a token
string, a `TokenDetails` or a `TokenRequest`.

## Migrating from 1.x

Version 2.0 renames the package and creates clients with `createClient`.

| | 1.x | 2.0 |
|---|---|---|
| Package | `ably_flutter` | `ably_pubsub_device_flutter` |
| Import | `package:ably_flutter/ably_flutter.dart` | `package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart` |
| Realtime client | `ably.Realtime(options: ...)` | `ably.createClient(options: ...)` |
| REST client | `ably.Rest(options: ...)` | Removed |

See [UPDATING.md](https://github.com/ably/ably-pubsub-flutter/blob/main/UPDATING.md#upgrading-from-v12x) for all other changes.

## Common configuration

### Endpoint

`endpoint` selects the Ably host for HTTP requests and the realtime connection. It replaces
the 1.x `environment`, `restHost` and `realtimeHost` options.

```dart
final client = ably.createClient(
  options: ably.ClientOptions(
    authUrl: 'https://your-server.example.com/ably-auth',
    clientId: 'me',
    endpoint: 'nonprod:sandbox',
  ),
);
```

- Never put a port in `endpoint`: `localhost:8080` is not a hostname and does not resolve.
- Set the port with `tlsPort`, or with `port` when TLS is off.
- With TLS off (`tls: false`), use token authentication.

See [UPDATING.md](https://github.com/ably/ably-pubsub-flutter/blob/main/UPDATING.md#upgrading-from-v12x) for how the old options map to `endpoint`.

### Logging

Set `logLevel` to a `LogLevel` value: `none`, `verbose`, `debug`, `info`, `warn` or `error`. The
default is `info`. The native SDK writes the log output; there is no log handler option.

```dart
final client = ably.createClient(
  options: ably.ClientOptions(
    authUrl: 'https://your-server.example.com/ably-auth',
    clientId: 'me',
    logLevel: ably.LogLevel.debug,
  ),
);
```

## Platform notes

### Push notifications

The SDK can activate a device for push notifications and subscribe it to channels. Push works on:

- Android devices, and Android emulators with Google APIs
- Physical iOS devices, but not the iOS Simulator

See [PushNotifications.md](https://github.com/ably/ably-pubsub-flutter/blob/main/PushNotifications.md) for setup, sending and receiving.

## Known limitations

- The Push Admin API is not available. The push APIs manage the current device only. See
  [Known Limitations](https://github.com/ably/ably-pubsub-flutter/blob/main/PushNotifications.md#known-limitations) in PushNotifications.md.

## Further reading

- [Getting started with Pub/Sub using Flutter](https://ably.com/docs/getting-started/flutter)
- [Ably Pub/Sub documentation](https://ably.com/docs/basics) and [examples](https://ably.com/examples?product=pubsub)
- [UPDATING.md](https://github.com/ably/ably-pubsub-flutter/blob/main/UPDATING.md): migrating from 1.x
- [CHANGELOG.md](https://github.com/ably/ably-pubsub-flutter/blob/main/CHANGELOG.md): release notes; all Ably releases are listed on [changelog.ably.com](https://changelog.ably.com)
- [PushNotifications.md](https://github.com/ably/ably-pubsub-flutter/blob/main/PushNotifications.md): push notifications on Android and iOS
- [example/](https://github.com/ably/ably-pubsub-flutter/tree/main/example): an example app

## Contributing

Read [CONTRIBUTING.md](https://github.com/ably/ably-pubsub-flutter/blob/main/CONTRIBUTING.md) before contributing; it also describes the release
process.

## Support, feedback and troubleshooting

For help, visit Ably's [support page](https://ably.com/support). Report bugs and compatibility
problems on [GitHub Issues](https://github.com/ably/ably-pubsub-flutter/issues).

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](https://github.com/ably/ably-pubsub-flutter/blob/main/LICENSE).
