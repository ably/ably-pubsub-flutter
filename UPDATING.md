# Updating / Migration Guide

This guide lists the changes needed to upgrade from one version of Ably to a newer one when there are breaking changes.

## [Upgrading from v1.2.44]

This release adds support for Apple's [UIScene life cycle](https://developer.apple.com/documentation/uikit/scenes), which UIKit apps built against the SDK released after iOS 26 will be required to use.

- Updated Dart SDK constraint to `>=3.10.0 <4.0.0` and Flutter constraint to `>=3.38.0`. Flutter 3.38 is the first release exposing the plugin APIs needed for the UIScene life cycle.
- The minimum supported iOS version is now 13, up from 10. Raise `IPHONEOS_DEPLOYMENT_TARGET` and your Podfile's `platform :ios` to at least `13.0` if they are lower.
- **If your iOS app has adopted the UIScene life cycle** — that is, its `Info.plist` declares a `UIApplicationSceneManifest` — you must now register Ably's push notification handlers from your `AppDelegate`:

  ```swift
  import ably_flutter

  @main
  @objc class AppDelegate: FlutterAppDelegate {
      override func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {
          AblyFlutter.sharedInstance().registerPushNotificationHandlers()

          GeneratedPluginRegistrant.register(with: self)
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
  }
  ```

  Apple requires the `UNUserNotificationCenterDelegate` to be set before `application:didFinishLaunchingWithOptions:` returns, but Flutter defers plugin registration until after that for scene-based apps, so the plugin can no longer install it early enough by itself. See [Push notifications: UIScene life cycle](./PushNotifications.md#uiscene-life-cycle).

  Apps still on the `UIApplicationDelegate` life cycle need no changes. Adding the call anyway is safe, so you can add it before migrating.
- `AblyFlutter` no longer declares conformance to `UNUserNotificationCenterDelegate`. It never implemented any of those methods, so installing it as the notification centre's delegate had no effect. Use `registerPushNotificationHandlers` instead.

## [Upgrading from v1.2.13]

- Updated SDK constraint to `>=2.14.0 <3.0.0`
- Updated Flutter constraint to `>=2.5.0`

## [Upgrading from v1.2.12]

- `TokenDetails`, `TokenParams` and `TokenRequest` classes are now immutable, parameters have to be passed through constructor

## [Upgrading from v1.2.8]

Changes made at v1.2.9:

- `ably.Push.pushEvents` is renamed to `ably.Push.activationEvents`, to be more meaningful. It provides access to events related to setting up push notification, such as activation, deactivation and notification permission. This was done to help future users clearly distinguish between `activationEvents` and `notificationEvents`.
- When instantiating `Rest` or `Realtime` with an API key, replace `ably.Rest(key: yourApiKey)` with `ably.Rest.fromKey(yourApiKey)`. This was done because using `ably.Rest(key: yourApiKey, options: clientOptions)` was misleading (`yourApiKey` was ignored).
