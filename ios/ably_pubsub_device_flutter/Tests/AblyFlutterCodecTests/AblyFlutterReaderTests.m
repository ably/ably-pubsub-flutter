#import <XCTest/XCTest.h>
#import <Flutter/Flutter.h>
@import AblyPubSubDevice;
@import AblyFlutterCommon;

// Exercise the production decoder without making its header part of the public API.
#import "../../Sources/ably_pubsub_device_flutter/codec/AblyFlutterReader.h"

@interface AblyFlutterReaderTests : XCTestCase
@end

@implementation AblyFlutterReaderTests

// Match Dart's ClientOptions wire format using Flutter's real standard codec.
- (ARTClientOptions*)decodeClientOptions:(NSDictionary*)options {
    NSMutableData *data = [NSMutableData data];
    FlutterStandardWriter *writer = [[FlutterStandardWriter alloc] initWithData:data];
    [writer writeByte:CodecTypeClientOptions];
    [writer writeValue:options];

    AblyFlutterReader *reader = [[AblyFlutterReader alloc] initWithData:data];
    AblyFlutterClientOptions *decoded = [reader readValue];
    XCTAssertTrue([decoded isKindOfClass:[AblyFlutterClientOptions class]]);
    XCTAssertNotNil(decoded.clientOptions);
    return decoded.clientOptions;
}

// A boxed false from Flutter must disable echoes on the native client.
- (void)testEchoMessagesFalseIsPreserved {
    ARTClientOptions *options = [self decodeClientOptions:@{TxClientOptions_echoMessages: @NO}];
    XCTAssertFalse(options.echoMessages,
        @"An explicit false must disable echoes instead of treating NSNumber as a truthy pointer");
}

// Explicit true must continue to enable echoes.
- (void)testEchoMessagesTrueIsPreserved {
    ARTClientOptions *options = [self decodeClientOptions:@{TxClientOptions_echoMessages: @YES}];
    XCTAssertTrue(options.echoMessages);
}

// An omitted option must preserve the native SDK's documented default.
- (void)testMissingEchoMessagesKeepsDefault {
    ARTClientOptions *options = [self decodeClientOptions:@{}];
    XCTAssertTrue(options.echoMessages);
}

// Null means the caller did not override the native default.
- (void)testNullEchoMessagesKeepsDefault {
    ARTClientOptions *options = [self decodeClientOptions:@{TxClientOptions_echoMessages: [NSNull null]}];
    XCTAssertTrue(options.echoMessages);
}

@end
