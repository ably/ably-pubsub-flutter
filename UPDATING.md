# Updating / Migration Guide

This guide lists the changes needed to upgrade from one version of Ably to a newer one when there are breaking changes.

## [Upgrading from v1.2.x]

- The package has been renamed from `ably_flutter` to `ably_pubsub_device_flutter`. Update the dependency in your `pubspec.yaml` and every import:
  - `ably_flutter: ^1.2.x` becomes `ably_pubsub_device_flutter: ^2.0.0`.
  - `import 'package:ably_flutter/ably_flutter.dart' as ably;` becomes `import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart' as ably;`.
  - On iOS, the pod and Swift module are renamed too, so an AppDelegate that did `import ably_flutter` now needs `import ably_pubsub_device_flutter`.
- On iOS, the plugin is now distributed as a Swift package rather than a CocoaPod, and requires Flutter 3.44 or later, where Swift Package Manager is enabled by default.
  - If your app has turned Swift Package Manager off (`enable-swift-package-manager: false` in `pubspec.yaml`, or `flutter config --no-enable-swift-package-manager`), turn it back on: the plugin no longer ships a podspec, so CocoaPods cannot install it. Other plugins that only support CocoaPods keep working alongside it.
  - The first iOS build after upgrading migrates your Xcode project to Swift Package Manager automatically. Afterwards, `pod install` no longer installs `ably_pubsub_device_flutter` or `Ably`, and if no other plugin needs CocoaPods you can remove your `Podfile`.
  - If you pinned `Ably` in your `Podfile`, remove that pin: the plugin now resolves `ably-cocoa` through Swift Package Manager, and a second copy from CocoaPods would conflict with it.
- The plugin is now built on the v2 native SDKs, [ably-pubsub-cocoa](https://github.com/ably/ably-pubsub-cocoa) 2.0 on iOS and [ably-pubsub-java](https://github.com/ably/ably-pubsub-java) 2.0 (`io.ably.pubsub:device`) on Android. This raises the platform floors and changes how clients reach and identify themselves to Ably:
  - The minimum iOS version is now iOS 15, and building requires Xcode 26 or later. The minimum Android version is now API level 24 (Android 7.0); set `minSdkVersion` to at least 24 in your app's `android/app/build.gradle`.
  - `ClientOptions.environment`, `ClientOptions.restHost` and `ClientOptions.realtimeHost` are removed. Use `ClientOptions.endpoint`, which selects one host for both REST requests and the realtime connection:
    - Replace `environment: 'sandbox'` with `endpoint: 'nonprod:sandbox'`, and any other `environment: 'acme'` with `endpoint: 'acme'`.
    - Replace `restHost` / `realtimeHost` with `endpoint` set to that host. Setting the two to different hosts is no longer supported. Don't put a port in `endpoint`; set `port` or `tlsPort` instead. A hostname `endpoint` has no default fallback hosts, so pass `fallbackHosts` if you need them.
  - Clients now connect to `main.realtime.ably.net` by default, with fallbacks at `main.[a-e].fallback.ably-realtime.com`, instead of `rest.ably.io`, `realtime.ably.io` and `[a-e].ably-realtime.com`. If your network restricts outbound traffic by hostname, allow `*.realtime.ably.net` and `*.fallback.ably-realtime.com`.
  - Every client declares to Ably that it runs on an end user's device. On an account billed by monthly active users, device traffic counts toward the total, and the connection must carry a `clientId`, set in `ClientOptions.clientId` or carried by the token. Authenticate devices with tokens from your own server (`authUrl` or `authCallback`) rather than embedding an API key in the app.
  - Clients identify themselves in the `Ably-Agent` header and the realtime `agent` parameter as `ably-pubsub-cocoa` or `ably-pubsub-java` with an `ably-pubsub-device` entry, where they sent `ably-cocoa` or `ably-java`. Update anything that matches on the old names, such as proxy rules or log queries.
  - On iOS, if your AppDelegate imports the native SDK directly, `import Ably` becomes `import AblyPubSubDeviceSwift` (or `@import AblyPubSubDevice;` in Objective-C), and Swift sees its types without the `ART` prefix. On Android, native code that uses the SDK directly moves from `io.ably.lib.*` to `io.ably.pubsub.*`.
- The `Realtime` client has been renamed to `PubSubClient`, and it is now created with the top-level `ably.createClient()` function rather than a constructor. `PubSubClient` no longer has a public constructor, and `Realtime.fromKey(key)` and the `key` parameter have both been removed; pass the key through `ClientOptions` instead.
  - Replace `ably.Realtime(options: clientOptions)` with `ably.createClient(options: clientOptions)`.
  - Replace `ably.Realtime.fromKey(key)` / `ably.Realtime(key: key)` with `ably.createClient(options: ably.ClientOptions(key: key))`.
- All previously deprecated API has been removed:
  - `Connection.recoveryKey`. Use `Connection.createRecoveryKey()`.
  - `ClientOptions.logHandler` and the `LogHandler` typedef. Log output is handled by the underlying native SDK; use `ClientOptions.logLevel` to control verbosity.
  - `ClientOptions.fallbackHostsUseDefault`. There is no replacement; default fallback hosts are used automatically unless `ClientOptions.fallbackHosts` is set.
  - `ClientOptions.fromKey(key)` and `AuthOptions.fromKey(key)`. Use the constructors' named `key` parameter instead.
- The REST client has been removed. Use `PubSubClient` instead:
  - Replace `ably.Rest(options: clientOptions)` / `ably.Rest.fromKey(key)` with `ably.createClient(options: clientOptions)` / `ably.createClient(options: ably.ClientOptions(key: key))`, and use `channels`, `auth`, `push` and `time()` on the `PubSubClient` in place of their `Rest` equivalents.
  - `RestChannel`, `RestChannels`, `RestPresence`, `RestChannelOptions`, `RestHistoryParams` and `RestPresenceParams` have been removed. Use `RealtimeChannel`, `RealtimeChannels`, `RealtimePresence`, `RealtimeChannelOptions`, `RealtimeHistoryParams` and `RealtimePresenceParams`.
  - `Message.fromEncoded`, `Message.fromEncodedArray`, `PresenceMessage.fromEncoded` and `PresenceMessage.fromEncodedArray` now take a `RealtimeChannelOptions` instead of a `RestChannelOptions`.
  - `Push` and `PushChannel` no longer accept a `rest` client; they now require a `realtime` client.
- `RealtimeChannels.release()` now returns a `Future<void>`, which completes once the channel has been released. A realtime channel can only be released when it is in the `INITIALIZED`, `DETACHED`, or `FAILED` state. Releasing a channel in any other state no longer detaches it implicitly. Instead, the future completes with an `AblyException` with code 90011 and the channel is not released. To release an attached channel, `await channel.detach()` first and then `await realtime.channels.release(name)`.

## [Upgrading from v1.2.13]

- Updated SDK constraint to `>=2.14.0 <3.0.0`
- Updated Flutter constraint to `>=2.5.0`

## [Upgrading from v1.2.12]

- `TokenDetails`, `TokenParams` and `TokenRequest` classes are now immutable, parameters have to be passed through constructor

## [Upgrading from v1.2.8]

Changes made at v1.2.9:

- `ably.Push.pushEvents` is renamed to `ably.Push.activationEvents`, to be more meaningful. It provides access to events related to setting up push notification, such as activation, deactivation and notification permission. This was done to help future users clearly distinguish between `activationEvents` and `notificationEvents`.
- When instantiating `Rest` or `Realtime` with an API key, replace `ably.Rest(key: yourApiKey)` with `ably.Rest.fromKey(yourApiKey)`. This was done because using `ably.Rest(key: yourApiKey, options: clientOptions)` was misleading (`yourApiKey` was ignored).
