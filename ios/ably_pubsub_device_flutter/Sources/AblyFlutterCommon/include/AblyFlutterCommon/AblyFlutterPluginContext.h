@import Foundation;
@import Flutter;

#import "AblyInstanceStore.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The plugin state a method-call handler needs.

 `AblyFlutter` conforms to this. Handlers written in Swift take it instead of
 `AblyFlutter` itself, because the Swift target cannot depend on the
 Objective-C target that defines the plugin class -- that target depends on it.
 */
@protocol AblyFlutterPluginContext <NSObject>

@property(nonatomic, readonly) AblyInstanceStore *instanceStore;
@property(nonatomic, readonly) FlutterMethodChannel *channel;

@end

NS_ASSUME_NONNULL_END
