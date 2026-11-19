# Xcode 27 / iOS 27 Support

Starting from **Geofence SDK v1.1.0**, the CleverTap Geofence SDK builds with **Xcode 27** and runs on **iOS 27**. Two things changed that may require action in your app:

1. The **minimum deployment target** was raised from iOS 10 to **iOS 15** (Xcode 27 no longer builds targets below its supported range).
2. Apps must adopt the **UIScene lifecycle** (required by iOS 26+ when built with the iOS 26/27 SDK).

---

## 1. Minimum deployment target

| Platform | Previous | New minimum |
| --- | --- | --- |
| iOS | 10.0 | **15.0** |

If your app targets a version below iOS 15, raise its deployment target. Xcode 27 fails the build with an error like:

```
error: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 10.0,
but the range of supported deployment target versions is 15.0 to 27.x.
```

The Geofence SDK uses `CoreLocation` only, so the raised floor removes no functionality.

### Also raise the CleverTap iOS SDK

The Geofence SDK depends on the CleverTap iOS SDK, which raised its own minimum to iOS 15 in the same release wave. Use a CleverTap iOS SDK version that supports Xcode 27, otherwise the core SDK target still declares iOS 9 and Xcode 27 fails on it.

---

## 2. CocoaPods: bump your pod deployment targets

Xcode 27 fails to build **any** target below iOS 15, and that includes transitive dependencies such as `SDWebImage` (pulled in by the CleverTap iOS SDK) that still declare an older minimum. Setting `platform :ios, '15.0'` in your `Podfile` is not always enough, because each pod can carry its own lower deployment target.

Add a `post_install` hook to your `Podfile` that raises every generated pod target, then run `pod install` again:

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!
  pod 'CleverTap-Geofence-SDK'
  pod 'CleverTap-iOS-SDK'
  # ...
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

> Already have a `post_install` block? Add the `IPHONEOS_DEPLOYMENT_TARGET` line inside it. Do not declare a second `post_install`.

### Swift Package Manager

Nothing to do beyond raising your app target to iOS 15. `Package.swift` already declares `.iOS(.v15)`.

---

## 3. Adopt the UIScene lifecycle

Starting with iOS 26, apps built with the iOS 26/27 SDK **must** use the `UIScene` lifecycle. An app that still uses the legacy app-delegate, window-based lifecycle - an `AppDelegate` with a `window` property, a `UIMainStoryboardFile` in `Info.plist`, and no scene manifest - **crashes at launch** on iOS 26 and later.

This is an app-side requirement, not a Geofence SDK change. See the [CleverTap iOS SDK iOS 27 guide](https://github.com/CleverTap/clevertap-ios-sdk/blob/master/docs/iOS27Support.md) for the full `SceneDelegate` migration steps.

### What this means for Geofence specifically

`CleverTapGeofence.shared.start(didFinishLaunchingWithOptions:)` is called from `application(_:didFinishLaunchingWithOptions:)`. That callback **still runs** under the scene lifecycle, so your Geofence start-up code does not move and needs no change.

The same holds for a location-triggered relaunch. iOS still wakes the app through `application(_:didFinishLaunchingWithOptions:)` with a location launch key, so region monitoring keeps working as before.

Geofence callbacks are delivered through `CLLocationManagerDelegate` and `NotificationCenter`, neither of which is tied to the app or scene lifecycle.

---

## Reference

| Topic | Where |
| --- | --- |
| Full `SceneDelegate` migration | [CleverTap iOS SDK iOS 27 guide](https://github.com/CleverTap/clevertap-ios-sdk/blob/master/docs/iOS27Support.md) |
| Geofence setup and Info.plist keys | [README](../README.md) |
| Geofence customization | [Customization.md](Customization.md) |
