@import Foundation;
@import Flutter;
@import AblyPubSubDevice;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterReader : FlutterStandardReader

+(ARTTokenDetails *)tokenDetailsFromDictionary: (NSDictionary *) dictionary;
+(ARTTokenParams *)tokenParamsFromDictionary: (NSDictionary *) dictionary;
+(NSDictionary<NSString *, ARTStringifiable *> *)transportParamsFromDictionary: (NSDictionary *) dictionary;

@end

NS_ASSUME_NONNULL_END
