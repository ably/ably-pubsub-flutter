# Updating / Migration Guide

This guide lists the changes needed to upgrade from one version of Ably to a newer one when there are breaking changes.

## [Upgrading from v1.2.x]

- The package has been renamed from `ably_flutter` to `ably_pubsub_device_flutter`. Update the dependency in your `pubspec.yaml` and every import:
  - `ably_flutter: ^1.2.x` becomes `ably_pubsub_device_flutter: ^2.0.0`.
  - `import 'package:ably_flutter/ably_flutter.dart' as ably;` becomes `import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart' as ably;`.
  - On iOS, the pod and Swift module are renamed too, so an AppDelegate that did `import ably_flutter` now needs `import ably_pubsub_device_flutter`.
- The REST client has been removed. Use the realtime client instead:
  - Replace `ably.Rest(options: clientOptions)` / `ably.Rest.fromKey(key)` with `ably.Realtime(options: clientOptions)` / `ably.Realtime.fromKey(key)`, and use `realtime.channels`, `realtime.auth`, `realtime.push` and `realtime.time()` in place of their `Rest` equivalents.
  - `RestChannel`, `RestChannels`, `RestPresence`, `RestChannelOptions`, `RestHistoryParams` and `RestPresenceParams` have been removed. Use `RealtimeChannel`, `RealtimeChannels`, `RealtimePresence`, `RealtimeChannelOptions`, `RealtimeHistoryParams` and `RealtimePresenceParams`.
  - `Message.fromEncoded`, `Message.fromEncodedArray`, `PresenceMessage.fromEncoded` and `PresenceMessage.fromEncodedArray` now take a `RealtimeChannelOptions` instead of a `RestChannelOptions`.
  - `Push` and `PushChannel` no longer accept a `rest` client; they now require a `realtime` client.

## [Upgrading from v1.2.13]

- Updated SDK constraint to `>=2.14.0 <3.0.0`
- Updated Flutter constraint to `>=2.5.0`

## [Upgrading from v1.2.12]

- `TokenDetails`, `TokenParams` and `TokenRequest` classes are now immutable, parameters have to be passed through constructor

## [Upgrading from v1.2.8]

Changes made at v1.2.9:

- `ably.Push.pushEvents` is renamed to `ably.Push.activationEvents`, to be more meaningful. It provides access to events related to setting up push notification, such as activation, deactivation and notification permission. This was done to help future users clearly distinguish between `activationEvents` and `notificationEvents`.
- When instantiating `Rest` or `Realtime` with an API key, replace `ably.Rest(key: yourApiKey)` with `ably.Rest.fromKey(yourApiKey)`. This was done because using `ably.Rest(key: yourApiKey, options: clientOptions)` was misleading (`yourApiKey` was ignored).
