import Foundation
import Flutter

// This class is used to replace the UNUserNotificationCenterDelegate set by the user.
//
// It makes sure to also call the same delegate methods implemented on the original
// UNUserNotificationCenter.delegate, if it exists
public class PushNotificationEventHandlers: NSObject, UNUserNotificationCenterDelegate {
    var delegate: UNUserNotificationCenterDelegate? = nil;

    // Nil until the plugin has been registered against a Flutter engine.
    //
    // Apple requires UNUserNotificationCenter.delegate to be set before
    // AppDelegate.didFinishLaunching returns, but for apps on the UIScene life cycle
    // Flutter defers plugin registration until after that. So this delegate can be
    // installed — and start receiving events — while there is still no channel to
    // forward them over. Each handler below says what it does in that window.
    private var methodChannel: FlutterMethodChannel? = nil;

    @objc(initWithDelegate:) public init(_ delegate: UNUserNotificationCenterDelegate?) {
        self.delegate = delegate;
    }

    @objc(attachMethodChannel:) public func attach(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel;
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let methodChannel = methodChannel else {
            // No engine to ask yet, so present nothing — the same outcome as a Dart
            // `setOnShowNotificationInForeground` handler returning false.
            completionHandler([])
            return
        }
        let message = RemoteMessage.fromNotificationContent(content:notification.request.content);
        methodChannel.invokeMethod(AblyPlatformMethod_pushOnShowNotificationInForeground, arguments: message) { result in
            if let result = result as? NSNumber, result == NSNumber(value: true) {
                if #available(iOS 14.0, *) {
                    completionHandler(.banner)
                } else {
                    completionHandler(.alert)
                }
            } else {
                completionHandler([])
            }
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        if let methodChannel = methodChannel {
            let remoteMessage = RemoteMessage.fromNotificationContent(content: content)
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnNotificationTap, arguments: remoteMessage, result: nil)
        } else {
            // No engine yet means this tap is what launched the app, so record it for
            // the `notificationTapLaunchedAppFromTerminated` query Dart makes once it
            // starts up. Under the UIScene life cycle this is the only way the payload
            // reaches Dart, because `didFinishLaunchingWithOptions` no longer receives
            // launch options.
            PushHandlers.pushNotificationTapLaunchedAppFromTerminatedData = content.userInfo
        }

        // `as` is used because userNotificationCenter on its own is ambiguous (userNotificationCenter corresponds to 3 methods).
        // See https://stackoverflow.com/questions/35658334/how-do-i-resolve-ambiguous-use-of-compile-error-with-swift-selector-syntax
        let didReceiveDelegateMethodSelector = #selector(userNotificationCenter as (UNUserNotificationCenter, UNNotificationResponse, @escaping () -> Void) -> Void)
        if let delegate = delegate, delegate.responds(to: didReceiveDelegateMethodSelector) {
            // Allow users AppDelegate gets a chance to respond.
            delegate.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        } else {
            completionHandler()
        }
    }

    @available(iOS 12.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        methodChannel?.invokeMethod(AblyPlatformMethod_pushOpenSettingsFor, arguments: nil, result: nil)
        let openSettingsForDelegateMethodSelector = #selector(userNotificationCenter as (UNUserNotificationCenter, UNNotification?) -> Void)
        if let delegate = delegate, delegate.responds(to: openSettingsForDelegateMethodSelector) {
            delegate.userNotificationCenter?(center, openSettingsFor: notification)
        }
    }

    @objc
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let methodChannel = methodChannel else {
            completionHandler(.noData);
            return
        }

        var methodName = AblyPlatformMethod_pushOnMessage;
        if (application.applicationState == .background || application.applicationState == .inactive) {
            methodName = AblyPlatformMethod_pushOnBackgroundMessage
        }

        let remoteMessage = RemoteMessage(data: userInfo._bridgeToObjectiveC(), notification: Notification(from: userInfo));
        methodChannel.invokeMethod(methodName, arguments: remoteMessage) { flutterResult in
            completionHandler(.newData);
        }
    }
}
