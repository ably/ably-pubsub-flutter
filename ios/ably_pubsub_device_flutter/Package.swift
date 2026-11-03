// swift-tools-version: 5.9

import PackageDescription

// SwiftPM does not allow Objective-C and Swift in the same target, and this
// plugin's two languages call into each other. The cycle is broken by layering
// it into three targets:
//
// - AblyFlutterCommon (Objective-C): the types both languages share -- the
//   instance store, message wrappers, platform constants and the
//   `AblyFlutterPluginContext` protocol handlers receive.
// - AblyFlutterSwift (Swift): method-call handlers, push notification glue and
//   encoders. Depends only on AblyFlutterCommon.
// - ably_pubsub_device_flutter (Objective-C): the `AblyFlutter` plugin class
//   Flutter registers, and the codec. Depends on both of the above.
let package = Package(
    name: "ably_pubsub_device_flutter",
    platforms: [
        // ably-pubsub-cocoa 2.0 requires iOS 15.
        .iOS("15.0")
    ],
    products: [
        .library(name: "ably-pubsub-device-flutter", targets: ["ably_pubsub_device_flutter"])
    ],
    dependencies: [
        // Provided by the Flutter tool alongside this package when it builds an app.
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/ably/ably-pubsub-cocoa", exact: "2.0.0"),
    ],
    targets: [
        .target(
            name: "ably_pubsub_device_flutter",
            dependencies: [
                "AblyFlutterCommon",
                "AblyFlutterSwift",
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AblyPubSubDevice", package: "ably-pubsub-cocoa"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            cSettings: [
                .headerSearchPath("include/ably_pubsub_device_flutter")
            ]
        ),
        .target(
            name: "AblyFlutterSwift",
            dependencies: [
                "AblyFlutterCommon",
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AblyPubSubDevice", package: "ably-pubsub-cocoa"),
            ]
        ),
        .target(
            name: "AblyFlutterCommon",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AblyPubSubDevice", package: "ably-pubsub-cocoa"),
            ],
            cSettings: [
                // Lets the implementation files import their public headers by
                // bare name, as the generated AblyPlatformConstants.m does.
                .headerSearchPath("include/AblyFlutterCommon")
            ]
        ),
        .testTarget(
            name: "AblyFlutterCommonTests",
            dependencies: [
                "AblyFlutterCommon",
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ]
        ),
        .testTarget(
            name: "AblyFlutterCodecTests",
            dependencies: [
                "ably_pubsub_device_flutter",
                "AblyFlutterCommon",
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AblyPubSubDevice", package: "ably-pubsub-cocoa"),
            ]
        ),
    ]
)
