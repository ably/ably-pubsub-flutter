import AblyPubSubDevice
import AblyFlutterCommon
import Flutter
import Foundation

public class CryptoCodec: NSObject {
    
    @objc
    public static let readCipherParams: (Dictionary<String, Any>) -> CipherParams = { dictionary in
        let algorithm = dictionary[TxCipherParams_iosAlgorithm] as! String
        let key = dictionary[TxCipherParams_iosKey] as! FlutterStandardTypedData
        return CipherParams(algorithm: algorithm, key: key.data as NSData)
    }
    
    @objc
    public static let encodeCipherParams: (CipherParams) -> Dictionary<String, Any> = { cipherParams in
        return [
            TxCipherParams_iosKey: cipherParams.key,
            TxCipherParams_iosAlgorithm: cipherParams.algorithm,
        ];
    }
    
    @objc
    public static let readRealtimeChannelOptions: (Dictionary<String, Any>) -> RealtimeChannelOptions = { dictionary in
        var channelOptions: RealtimeChannelOptions;
        if let cipherParamsDictionary = dictionary[TxRealtimeChannelOptions_cipherParams] as? Dictionary<String, Any> {
            channelOptions = RealtimeChannelOptions(cipher: readCipherParams(cipherParamsDictionary))
        } else {
            channelOptions = RealtimeChannelOptions()
        }
        
        channelOptions.params = dictionary[TxRealtimeChannelOptions_params] as? Dictionary<String, String>
        let modesStrings = dictionary[TxRealtimeChannelOptions_modes] as? [String]
        channelOptions.modes = []
        modesStrings?.forEach { mode in
            if let mode = ChannelMode.from(mode: mode) {
                channelOptions.modes.insert(mode)
            }
        }
        return channelOptions
    }
}

extension ChannelMode {
    static func from(mode: String) -> ChannelMode? {
        switch(mode) {
        case TxEnumConstants_presence:
            return ChannelMode.presence
        case TxEnumConstants_subscribe:
            return ChannelMode.subscribe
        case TxEnumConstants_publish:
            return ChannelMode.publish
        case TxEnumConstants_presenceSubscribe:
            return ChannelMode.presenceSubscribe
        default: return nil
        }
    }
    
    func toString() -> [String] {
        var modes: [String] = [];
        if self.contains(ChannelMode.presence) {
            modes.append(TxEnumConstants_presence)
        }
        if self.contains(ChannelMode.subscribe) {
            modes.append(TxEnumConstants_subscribe)
        }
        if self.contains(ChannelMode.publish) {
            modes.append(TxEnumConstants_publish)
        }
        if self.contains(ChannelMode.presenceSubscribe) {
            modes.append(TxEnumConstants_presenceSubscribe)
        }
        return modes
    }
}
