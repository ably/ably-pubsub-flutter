import AblyPubSubDevice
import AblyFlutterCommon
import Flutter
import Foundation
import UserNotifications

public class PushHandlers: NSObject {
    @objc
    public static var pushNotificationTapLaunchedAppFromTerminatedData: Dictionary<AnyHashable, Any>? = nil;

    @objc
    public static let activate: FlutterHandler = { ably, call, result in
        if let push = getPush(instanceStore: ably.instanceStore, call: call, result: result) {
            PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForActivate = result
            push.activate()
        } else {
            result(FlutterError(code: "PushHandlers#activate", message: "Cannot get push from client", details: nil))
        }
    }

    @objc
    public static let deactivate: FlutterHandler = { ably, call, result in
        if let push = getPush(instanceStore: ably.instanceStore, call: call, result: result) {
            PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForDeactivate = result
            push.deactivate()
        } else {
            result(FlutterError(code: "PushHandlers#deactivate", message: "Cannot get push from client", details: nil))
        }
    }

    @objc
    public static let getNotificationSettings: (_ ably: AblyFlutterPluginContext, _ call: FlutterMethodCall, _ result: @escaping (_ result: Any?) -> Void) -> Void = { ably, call, result in
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            result(settings)
        }
    }

    @objc
    public static let requestPermission: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let dataMap = ablyMessage.message as! Dictionary<String, Any>

        var options: UNAuthorizationOptions = []

        if (dataMap[TxPushRequestPermission_badge] as! Bool) {
            options.insert(.badge)
        }
        if (dataMap[TxPushRequestPermission_sound] as! Bool) {
            options.insert(.sound)
        }
        if (dataMap[TxPushRequestPermission_alert] as! Bool) {
            options.insert(.alert)
        }
        if (dataMap[TxPushRequestPermission_carPlay] as! Bool) {
            options.insert(.carPlay)
        }
        if (dataMap[TxPushRequestPermission_criticalAlert] as! Bool) {
            if #available(iOS 12.0, *) {
                options.insert(.criticalAlert)
            }
        }
        if (dataMap[TxPushRequestPermission_provisional] as! Bool) {
            if #available(iOS 12.0, *) {
                options.insert(.provisional)
            }
        }
        if (dataMap[TxPushRequestPermission_providesAppNotificationSettings] as! Bool) {
            if #available(iOS 12.0, *) {
                options.insert(.providesAppNotificationSettings)
            }
        }
        if (dataMap[TxPushRequestPermission_announcement] as! Bool) {
            if #available(iOS 13.0, *) {
                options.insert(.announcement)
            }
        }

        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            guard error == nil else {
                result(FlutterError(code: String(error!._code), message: "Error requesting authorization to show user notifications; err = \(error!.localizedDescription)", details: nil))
                return
            }
            result(NSNumber(booleanLiteral: granted))
        }
    }

    @objc
    public static let device: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)

        if let realtime = realtime {
            result(realtime.device)
        }
    }

    @objc
    public static let listSubscriptions: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        let params = dataMap[TxTransportKeys_params] as! Dictionary<String, String>

        // ably-pubsub-cocoa raises NSInvalidArgumentException, which Swift cannot
        // catch, unless exactly one of deviceId and clientId is given.
        guard (params["deviceId"] != nil) != (params["clientId"] != nil) else {
            result(FlutterError(code: "listSubscriptions_error", message: "Exactly one of deviceId and clientId must be given to list push channel subscriptions", details: nil))
            return
        }

        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.listSubscriptions(params, callback: { paginatedSubscription, errorInfo in
                if let errorInfo = errorInfo {
                    result(FlutterError(code: String(errorInfo.code), message: "Error listing subscriptions from push Channel \(pushChannel); err = \(errorInfo.message)", details: nil))
                    return
                }
                let handle = ably.instanceStore.setPaginatedResult(paginatedSubscription as! PaginatedResult<AnyObject>, handle: nil)
                result(AblyFlutterMessage(message: paginatedSubscription as Any, handle: handle))
            })
        }
    }

    @objc
    public static let subscribeDevice: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.subscribeDevice()
            result(nil)
        }
    }

    @objc
    public static let unsubscribeDevice: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.unsubscribeDevice()
            result(nil)
        }
    }

    @objc
    public static let subscribeClient: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.subscribeClient()
            result(nil)
        }
    }

    @objc
    public static let unsubscribeClient: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.unsubscribeClient()
            result(nil)
        }
    }

    @objc
    public static let pushNotificationTapLaunchedAppFromTerminated: FlutterHandler = { ably, call, result in
        if let data = pushNotificationTapLaunchedAppFromTerminatedData {
            result(pushNotificationTapLaunchedAppFromTerminatedData)
        }
    }

    /// Gets the client.push property from PubSubClient when the call contains a handle.
    private static func getPush(instanceStore: AblyInstanceStore, call: FlutterMethodCall, result: @escaping FlutterResult) -> Push? {
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = instanceStore.realtime(from: ablyMessage.handle)

        if let realtime = realtime {
            return realtime.push;
        }

        result(FlutterError(code: String(40000), message: "No ably client exists", details: nil))
        return nil;
    }

    /// Gets the client.channels.get(channelName).push property from PubSubClient
    /// when the call contains the clients handle and a channelName.
    ///
    /// The dart side can provide a handle (Int) which gets a PubSubClient Ably client.
    /// This function will callback the with the push channel for the channelName and client handle you provide.
    private static func getPushChannel(ably: AblyFlutterPluginContext, call: FlutterMethodCall, result: @escaping FlutterResult) -> PushChannel? {
        let ablyMessage = call.arguments as! AblyFlutterMessage

        /// Using `guard let handle` in that case caused compilation errors for some users
        /// See https://github.com/ably/ably-flutter/issues/347 for more information and
        let optionalHandle: NSNumber? = ablyMessage.handle
        var optionalChannelName: String?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            optionalChannelName = dataMap[TxTransportKeys_channelName] as? String
        }

        guard let handle: NSNumber = optionalHandle else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "clientHandle was null", details: nil))
            return nil
        }
        guard let channelName: String = optionalChannelName else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "channelName was null", details: nil))
            return nil
        }

        let instanceStore = ably.instanceStore
        if let realtime = instanceStore.realtime(from: handle) {
            return realtime.channels.get(channelName).push
        } else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "No ably client exists for that handle.", details: nil))
            return nil
        }
    }
}
