// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "clevertap-geofence-ios",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "CleverTapGeofence",
            targets: ["CleverTapGeofence"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CleverTap/clevertap-ios-sdk.git", .upToNextMajor(from: "3.9.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.1.2")),
    ],
    targets: [
        .target(
            name: "CleverTapGeofence",
            dependencies: [
                .product(name: "CleverTapSDK", package: "clevertap-ios-sdk")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CleverTapGeofenceTests",
            dependencies: [
                "CleverTapGeofence",
                .product(name: "CleverTapSDK", package: "clevertap-ios-sdk"),
                "Quick",
                "Nimble"
            ],
            resources: [.copy("CleverTapGeofence.xctestplan")]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
