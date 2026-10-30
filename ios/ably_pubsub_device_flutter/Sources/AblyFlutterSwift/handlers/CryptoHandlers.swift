import AblyPubSubDevice
import AblyFlutterCommon
import Flutter
import Foundation

public class CryptoHandlers: NSObject {
    @objc
    public static let getParams: FlutterHandler = { plugin, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let message = ablyMessage.message as! Dictionary<String, Any>
        let algorithm = message[TxCryptoGetParams_algorithm] as! String
        let key = message[TxCryptoGetParams_key]

        if let key = key as? NSString {
            result(CipherParams(algorithm: algorithm, key: key))
            return
        } else if let key = key as? FlutterStandardTypedData {
            result(CipherParams(algorithm: algorithm, key: key.data as NSData))
            return
        } else if let key = key {
            result(FlutterError(code: "CryptoHandlers_getParams", message: "Key must be a String or FlutterStandardTypedData, it is \(type(of: key))", details: nil))
        } else {
            result(FlutterError(code: "CryptoHandlers_getParams", message: "A key must be set for encryption", details: nil))
        }
    }
    
    @objc
    public static let generateRandomKey: FlutterHandler = { plugin, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let message = ablyMessage.message as! Dictionary<String, Any>
        let keyLength = message[TxCryptoGenerateRandomKey_keyLength] as! Int;
        result(Crypto.generateRandomKey(UInt(keyLength)));
    }
}
