# Change Log
All notable changes to this project will be documented in this file.

### [Version 2.0.0](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/2.0.0) (November 20, 2026)
* Supports the latest CleverTap iOS SDK(7.9.1)
* Adds Xcode 27 and iOS 27 support. The SDK builds with Xcode 27 and runs on iOS 27.
  * Minimum deployment target is now iOS 15.0 (previously iOS 10.0). Xcode 27 does not build targets below this range.
  * CocoaPods users may also need a `post_install` hook that raises every pod target to iOS 15, because dependencies such as `SDWebImage` carry their own lower minimums.
  * The `CleverTapGeofence` framework target no longer advertises Mac Catalyst support, so Carthage and manual framework builds are iOS-only. The CleverTap iOS SDK ships no Mac Catalyst slice, so Catalyst builds were never usable.
  * See [the iOS 27 Support doc](https://github.com/CleverTap/clevertap-geofence-ios/blob/master/Docs/iOS27Support.md) for the migration steps.
* Reduced SPM download size. The vendored CleverTap iOS SDK submodule and the committed framework binaries under `Vendors/` have been removed, so a Swift Package Manager checkout now fetches only the Geofence sources.
  * Manual integration now gets the CleverTap iOS SDK through Swift Package Manager instead of `Vendors/`. Apps integrating manually must embed `CleverTapSDK.framework` and `SDWebImage.framework` alongside `CleverTapGeofence.framework`. See [the Customization doc](https://github.com/CleverTap/clevertap-geofence-ios/blob/master/Docs/Customization.md#manual).

### [Version 1.0.7](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.7) (March 21, 2025)
* Supports the latest CleverTap iOS SDK(7.1.1)

### [Version 1.0.6](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.6) (April 22, 2024)
* Supports the latest CleverTap iOS SDK(6.2.1)
* Fixes a build error related to privacy manifests when statically linking the SDK using Cocoapods.

### [Version 1.0.5](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.5) (March 20, 2024)
* Supports the latest CleverTap iOS SDK(6.1.0)
* Adds XCPrivacy Manifests File

### [Version 1.0.4](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.4) (September 26, 2023)
* Supports the latest CleverTap iOS SDK via SPM.
* Updates Example Applications.

### [Version 1.0.3](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.3) (November 18, 2022)
* Adds support for installation via Swift Package Manager
* Updates Starter Applications

### [Version 1.0.2](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.2) (July 22, 2022)
* Updated to new pod `CleverTap-Geofence-SDK`.
* Compatible with latest CleverTap iOS SDK.

### [Version 1.0.1](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.1) (September 28, 2020)
##### Added
* Updates for iOS 14 Location Permission changes:
  - Adds logging when the user has opted for `reducedAccuracy` option in `accuracyAuthorization` permission since app can’t use region monitoring. Check more [here](https://developer.apple.com/documentation/corelocation/cllocationmanager/3600215-accuracyauthorization).

##### Breaking
* Requires Xcode 12 for targeting iOS 14.

### [Version 1.0.0](https://github.com/CleverTap/clevertap-geofence-ios/releases/tag/1.0.0) (September 7, 2020)
* First release of CleverTap iOS Geofence SDK 


