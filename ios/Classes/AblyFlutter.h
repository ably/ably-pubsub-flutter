#import <Flutter/Flutter.h>
#import "AblyInstanceStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject<FlutterPlugin, FlutterSceneLifeCycleDelegate>

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

/**
 The plugin instance shared by the process.

 Exposed so that apps can reach the plugin from their `AppDelegate` before
 Flutter has registered it — see `registerPushNotificationHandlers`.
 */
+(instancetype)sharedInstance;

/**
 Installs Ably's `UNUserNotificationCenterDelegate`, wrapping whichever delegate
 is already installed so that it still receives the events it handles.

 Apps that have adopted the UIScene life cycle **must** call this from their
 `application:didFinishLaunchingWithOptions:`. Apple requires
 `UNUserNotificationCenter.delegate` to be set before that method returns, but
 Flutter defers plugin registration until afterwards, so the plugin cannot
 install the delegate early enough by itself.

 Apps still on the `UIApplicationDelegate` life cycle need not call this: plugin
 registration does it for them. Calling it is safe either way — repeat calls are
 ignored rather than wrapping the delegate a second time.

 This does nothing if `AblyFlutterHandlePushNotifications` is set to `NO` in the
 app's `Info.plist`, which opts out of Ably handling push notifications at all.
 */
-(void)registerPushNotificationHandlers;

@property(nonatomic) AblyInstanceStore * instanceStore;
@property(nonatomic) FlutterMethodChannel *channel;

@end

NS_ASSUME_NONNULL_END
