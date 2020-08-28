<p align="center">
  <img src="https://github.com/CleverTap/clevertap-segment-ios/blob/master/clevertap-logo.png" width="230"/>
</p>

## Introduction

CleverTap Geofence SDK provides Geofencing capabilities to CleverTap iOS SDK by using Core Location framework.

## Table of Contents

* [Installation](#installation)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)
  - [Manual](#manual)
* [Integration](#integration)
* [Alternate Initialization](#alternate-initialization)
* [Stop Monitoring](#stop-monitoring)
* [Logging](#logging)
* [Geofence Notifications](#geofence-notifications)
* [Example Usage](#example-usage)
* [ChangeLog](#changelog)
* [Help and Questions](#help-and-questions)

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for iOS projects. To integrate CleverTap Geofence SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
pod 'CleverTapGeofence'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate CleverTap Geofence SDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "CleverTap/clevertap-geofence-ios"
```

### Manual

CleverTap Geofence SDK can also be integrated manually without any dependency manager. However, this is not a recommended way of integrating. Moreover, the following steps will have to be repeated again for updating to future release versions.

- Download the latest framework release. Unzip the download.

- Add the CleverTapGeofence.xcodeproj to your Xcode Project, by dragging the CleverTapGeofence.xcodeproj under the main project file.

- Embed the framework. Select your app.xcodeproj file. Under "General", add the CleverTapGeofence framework as an embedded binary.


## Integration
[(Back to Top)](#table-of-contents)

CleverTap Geofence utilizes Core Location APIs to setup up Geofences Region monitoring.
 The CleverTap Geofence will **NOT** request Location permissions from the user. Location Permission has to requested by the app as deemed fit while onboarding the user to the app.
Following are required -
- CleverTap iOS SDK version 3.9.0 or above
- Swift version 5.1 or above
- iOS version 10.0 or above
- CoreLocation iOS Framework
- Ensure that `Location Updates` in `Background Modes` is enabled for your App Target. You can enable this in Xcode by -
  - Click on your `AppTarget` in Xcode Project Navigator
  - Click on `Signing & Capabilities` tab 
  - Click on `+ Capability` button
  - Select the `Background Modes` option
  - Enable `Location Updates` by selecting the checkbox
- In your Info.plist file, add the following keys -
  - `NSLocationAlwaysAndWhenInUseUsageDescription` also known as `Privacy - Location Always and When In Use Usage Description`
   This is a key which accepts a String description to be used by iOS while requesting Location permission from user.

  - `NSLocationWhenInUseUsageDescription` also known as `Privacy - Location When In Use Usage Description`
  This is a key which accepts a String description to be used by iOS while requesting Location permission from user.

  - `UIBackgroundModes` also known as `Required background modes`
  This is a key which accepts an Array of items. This should include the `location` also known as `App registers for location updates` item to enable Background Location monitoring.

  *For iOS 11 only*: If your app targets iOS 11 then along with the above mentioned 3 Info.plist keys, the following key is also required. If your app target is iOS 12 or above, following is not required -
  - `NSLocationAlwaysUsageDescription` also know as `Privacy - Location Always Usage Description`
  This is a key which accepts a String description to be used by iOS while requesting Location permission from user. Only required for iOS 11.


  Following is an example of all the Info.plist keys in Source Code format -

  ```
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>App needs your location to provide enhanced features.</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>App needs your location to provide enhanced features.</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>App needs your location to provide enhanced features.</string>
  <key>UIBackgroundModes</key>
  <array>
    <string>location</string>
    <string>remote-notification</string>
    <string>fetch</string>
    <string>processing</string>
  </array>
  ```



- In your `AppDelegate` file, import the CleverTapGeofence module:

  ```
  // Swift
  import CleverTapGeofence

  // Objective-C
  #import <CleverTapGeofence/CleverTapGeofence-Swift.h>
  ```
  
- In your AppDelegate's `application:didFinishLaunchingWithOptions:` function, add the following the code snippet:

  ```
  // Swift
  CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)

  // Objective-C
  [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions];
  ```
  
- CleverTap Geofence SDK requires location permission from users to provide the Geofencing capabilities. The App is expected to request Location permission from user at an appropriate time. Once CleverTap Geofence SDK detects that Location permission has been given by user, only then the module will start to perform it's functions.

An example of how an app can request location permission is below:

  ```
  // Swift
  let locationManager = CLLocationManager()
  locationManager.requestAlwaysAuthorization()

  // Objective-C 
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  [locationManager requestAlwaysAuthorization];
  ```


## Alternate Initialization
[(Back to Top)](#table-of-contents)

You can **customize** the minimum distance & time filter for updating user's location using the following alternate initialization API:

  ```
  // Swift
  func start(didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?, distanceFilter: CLLocationDistance = 200, timeFilter: TimeInterval = 1800)

  // Objective-C
  - (void)startWithDidFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions distanceFilter:(CLLocationDistance)distanceFilter timeFilter:(NSTimeInterval)timeFilter;
  ```
  - `distanceFilter`: Specifies the minimum update distance in meters to be used by Geofence location manager. Client will not be notified of movements of less than the stated value, unless the accuracy has improved. By default, 200 meters is used.
  
  - `timeFilter`: Specifies the minimum time in seconds after which location should be updated. Location updates will not be triggered within less than the stated `timeFilter` value. By default, 1800 seconds is used.
  - Following is an example usage in AppDelegate's `application:didFinishLaunchingWithOptions:` function:
  
    ```
    // Swift
    CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions:launchOptions, distanceFilter: 200, timeFilter: 1800)

    // Objective-C
    [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions distanceFilter:200 timeFilter:1800];
    ```

## Stop Monitoring
[(Back to Top)](#table-of-contents)

You can **stop** CleverTap Geofence monitoring at any time using the following API:

  ```
  // Swift
  public func stop()

  // Objective-C
  - (void)stop;
  ```
  
  Following is an example usage within any function of app:
  
  ```
  // Swift
  func someScenarioWhereLocationMonitoringShouldBeOff() {   
    CleverTapGeofence.monitor.stop()
  }

  // Objective-C
  [[CleverTapGeofence monitor] stop];
  ```

## Logging
[(Back to Top)](#table-of-contents)

You can customize **Logging** mode to view more, less or no logs from the Geofence module. This can be done by appropriately setting the `CleverTapGeofenceLogLevel` enum:

  ```
  public enum CleverTapGeofenceLogLevel : Int {

    /// Only errors are logged to console. `.error` is the default
    case error

    /// Logs additional diagnostic info along with `.error` logs for debugging purposes.
    case debug

    /// Stops all logs from `CleverTapGeofence`
    case off
  }
  ```
  
  Ensure that `CleverTapGeofenceLogLevel` is set before invoking `start` function of CleverTap Geofence SDK. An example usage is as follows:
  
  ```
  // Swift
  CleverTapGeofence.logLevel = .debug
  // CleverTapGeofence.logLevel = .off
  CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)

  // Objective-C
  [CleverTapGeofence setLogLevel:CleverTapGeofenceLogLevelDebug];
  // [CleverTapGeofence setLogLevel:CleverTapGeofenceLogLevelOff];
  [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions];
  ```
  
## Geofence Notifications
[(Back to Top)](#table-of-contents)

You can **subscribe** to Geofence Enter & Exit event notifications to perform any customized actions within the app. 
`CleverTapGeofenceEntered` & `CleverTapGeofenceExited` notifications are fired by the CleverTap Geofence SDK whenever a users transits inside / outside a monitored geofence region. An example of subscribing to these notifications is as follows:

  ```
  // Swift 
  NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CleverTapGeofenceEntered"), object: nil, queue: OperationQueue.main) { (notification) in
      print("Perform custom action on Geofence Enter event")
  }

  NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CleverTapGeofenceExited"), object: nil, queue: OperationQueue.main) { (notification) in
      print("Perform custom action on Geofence Exit event")
  }

  // Objective-C
  [[NSNotificationCenter defaultCenter] addObserverForName:@"CleverTapGeofenceEntered" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
      NSLog(@"Perform custom action on Geofence Enter event");
  }]

  [[NSNotificationCenter defaultCenter] addObserverForName:@"CleverTapGeofenceExited" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
      NSLog(@"Perform custom action on Geofence Exit event");
  }]
  ```


## Example Usage

- A [demo application](https://github.com/CleverTap/clevertap-geofence-ios/tree/feature/SDK-104-geofence-support/Examples/CocoapodsExample) showing CocoaPods Installation.
- A [demo application](https://github.com/CleverTap/clevertap-geofence-ios/tree/feature/SDK-104-geofence-support/Examples/CarthageExample) showing Carthage Installation.


## ChangeLog

See the [CleverTap Geofence SDK Change Log](https://github.com/CleverTap/clevertap-geofence-ios/blob/feature/SDK-104-geofence-support/CHANGELOG.md)


## Help and Questions
[(Back to Top)](#table-of-contents)

If you have questions or concerns, you can reach out to the CleverTap Support Team from your CleverTap Dashboard.
