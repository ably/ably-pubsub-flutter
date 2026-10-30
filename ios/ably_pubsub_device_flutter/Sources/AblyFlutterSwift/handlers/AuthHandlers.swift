//
//  AuthHandlers.swift
//  ably_pubsub_device_flutter
//
//  Created by Ikbal Kaya on 17/03/2023.
//

import AblyPubSubDevice
import AblyFlutterCommon
import Flutter
import Foundation

public class AuthHandlers: NSObject {
   
    
    @objc
    public static let realtimeCreateTokenRequest: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: AuthOptions?
        var tokenParams: TokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? AuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? TokenParams
        }
        realtime?.auth.createTokenRequest(tokenParams, options: authOptions, callback: { (tokenRequest: TokenRequest?, error: Error?) in
            if let error = error {
                result(error)
                return
            }
            result(tokenRequest)
        })
    }
    
    @objc
    public static let realtimeAuthClientId: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let clientId =  realtime?.auth.clientId
        result(clientId)
    }
    
    @objc
    public static let realtimeAuthorize: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: AuthOptions?
        var tokenParams: TokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? AuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? TokenParams
        }
        
        realtime?.auth.authorize(tokenParams, options: authOptions, callback: { (details:TokenDetails?, error: Error?) in
            if let error = error {
                result(error)
                return
            }
            result(details)
            
        });
    }
    
    @objc
    public static let realtimeRequestToken: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: AuthOptions?
        var tokenParams: TokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? AuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? TokenParams
        }
        realtime?.auth.requestToken(tokenParams, with: authOptions, callback: { (details: TokenDetails?, error: Error?) in
            if let error = error {
                           result(error)
                           return
                       }
                       result(details)
        })
    
    }
}
