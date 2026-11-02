import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // With the UIScene life cycle, `FlutterSceneDelegate` creates the engine
    // once the scene connects, and plugins are registered here.
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("application:didFailToRegisterForRemoteNotificationsWithError was called with error: %@", error.localizedDescription)
    }

    /// An example of how you handle push notification if you opt-out from using Ably Pushes by adding `AblyFlutterHandlePushNotifications` equal to `NO` in your project's Info.plist file:
    ///
    /// (This method is deprecated, use the new one from `UNUserNotificationCenter` as recommented by Apple, it's here for the sake of simplest example)
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("Notification received: \(userInfo)")
    }
}
