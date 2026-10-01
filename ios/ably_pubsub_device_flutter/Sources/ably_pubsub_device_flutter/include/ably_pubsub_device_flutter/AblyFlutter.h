#import <Flutter/Flutter.h>
@import AblyFlutterCommon;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject<FlutterPlugin, UNUserNotificationCenterDelegate, AblyFlutterPluginContext>

+(instancetype)new NS_UNAVAILABLE;
+(instancetype)init NS_UNAVAILABLE;

@property(nonatomic) AblyInstanceStore * instanceStore;
@property(nonatomic) FlutterMethodChannel *channel;

@end

NS_ASSUME_NONNULL_END
