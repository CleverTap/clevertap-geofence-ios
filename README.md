<p align="center">
    <img src="https://github.com/CleverTap/clevertap-ios-sdk/blob/master/docs/images/clevertap-logo.png" width="50%"/>
</p>

[![Version](https://img.shields.io/cocoapods/v/CleverTapGeofence.svg?style=flat)](http://cocoapods.org/pods/CleverTapGeofence)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![codebeat badge](https://codebeat.co/badges/72d5f95b-6d33-4811-97fb-7c7cff001815)](https://codebeat.co/projects/github-com-clevertap-clevertap-geofence-ios-master)
[![Language](https://img.shields.io/badge/swift-5.1-orange.svg)](https://developer.apple.com/swift)
[![Platform](http://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## 👋 Introduction

CleverTap Geofence SDK provides Geofencing capabilities to CleverTap iOS SDK by using the Core Location framework. This document lists down steps to utilize CleverTap Geofence in your apps. You can further customize your integration of CleverTap Geofence by using the [Geofence Customization document](Docs/Customization.md).

## ⍗ Contents

- [Requirements](#-requirements)
- [Installation](#-installation)
    - [Via CocoaPods](#via-cocoapods)
    - [Via Swift Package Manager](#via-Swift Package Manager)   
- [Integration](#-integration)
- [Customization](#-customization)
- [Example Usage](#-example-usage)
- [Change Log](#-change-log)
- [Help and Questions](#-help-and-questions)
- [License](#-license)


## 📋 Requirements
Following are required for using CleverTap Geofence SDK -
- [CleverTap iOS SDK version 3.9.0 or above](https://github.com/CleverTap/clevertap-ios-sdk/releases)
- Swift version 5.1 or above
- iOS version 10.0 or above
- Xcode 12 for targeting iOS 14.x.x
- CoreLocation iOS Framework

## 🎉 Installation

#### Via CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for iOS projects. To integrate CleverTap Geofence SDK into your Xcode project using CocoaPods, specify the following in your `Podfile`:

```
pod 'CleverTap-Geofence-SDK'
pod 'CleverTap-iOS-SDK', :git => 'https://github.com/CleverTap/clevertap-ios-sdk.git'
```

You can refer to [Demo Applications](https://github.com/CleverTap/clevertap-geofence-ios/tree/master/Examples/CocoapodsExample) showcasing CocoaPods Installation.

#### Via Swift Package Manager

Swift Package Manager is an Xcode tool that installs project dependencies. To use it to install CleverTap Geofence SDK, follow these steps:

- In Xcode, navigate to **File -> Swift Package Manager -> Add Package Dependency.**
- Enter **https://github.com/CleverTap/clevertap-geofence-ios.git** when choosing package repo and Click **Next.**
- On the next screen, Select an SDK version (by default, Xcode selects the latest stable version). Click **Next.**
- Click **Finish** and ensure that the **CleverTap-Geofence-SDK** has been added to the appropriate target.

You can refer to [Demo Applications](https://github.com/CleverTap/clevertap-geofence-ios/tree/master/Examples/SPMSample) showcasing SPM Installation.

For installing CleverTap Geofence via [Carthage](Docs/Customization.md#carthage) or [Manually](Docs/Customization.md#manual), check out the steps in [Geofence Customization document](Docs/Customization.md#alternative-installation).

## 🚀 Integration

CleverTap Geofence utilizes Core Location APIs to setup up Geofences Region monitoring.
 The CleverTap Geofence will **NOT** request Location permissions from the user. Location Permission has to requested by the app as deemed fit while onboarding the user to the app.

**1.** In Xcode, enable `Location Updates` in `Background Modes` for your App Target. You can enable this in Xcode by -
  - Click on your `AppTarget` in Xcode Project Navigator
  - Click on `Signing & Capabilities` tab 
  - Click on `+ Capability` button
  - Select the `Background Modes` option
  - Enable `Location Updates` by selecting the checkbox
  
  ![Xcode Capabilities](Docs/Capabilities.png  "Capabilities")
  
**2.** In your `Info.plist` file, add the following keys -
  - `NSLocationAlwaysAndWhenInUseUsageDescription` also known as `Privacy - Location Always and When In Use Usage Description`
   This is a key that accepts a String description to be used by iOS while requesting Location permission from the user.

  - `NSLocationWhenInUseUsageDescription` also known as `Privacy - Location When In Use Usage Description`
  This is a key that accepts a String description to be used by iOS while requesting Location permission from the user.

  - `UIBackgroundModes` also known as `Required background modes`
  This is a key that accepts an Array of items. This should include the `location` also known as `App registers for location updates` item to enable Background Location monitoring.

  *For iOS 11 only*: If your app targets iOS 11 then along with the above mentioned 3 Info.plist keys, the following key is also required. If your app target is iOS 12 or above, the following is not required -
  - `NSLocationAlwaysUsageDescription` also know as `Privacy - Location Always Usage Description`
  This is a key that accepts a String description to be used by iOS while requesting Location permission from the user. Only required for iOS 11.


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
  
  ![Xcode Info.plist](Docs/Info-plist.png "Info.plist")



**3.** In your `AppDelegate` file, import the CleverTapGeofence module:

  ```
  // Swift
  import CleverTapGeofence

  // Objective-C
  @import CleverTapGeofence;
  ```
  
**4.** In your AppDelegate's `application:didFinishLaunchingWithOptions:` function, add the following the code snippet. 
Ensure that Geofence SDK initialization is done after CleverTap Main SDK initialization.

  ```
  // Swift
  CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)

  // Objective-C
  [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions];
  ```
 
**5.** CleverTap Geofence SDK requires location permission from users to provide the Geofencing capabilities. The App is expected to request Location permission from the user at an appropriate time. Once CleverTap Geofence SDK detects that Location permission has been given by the user, only then the module will start to perform its functions.

*iOS 14 Update:* If user has opted for `reducedAccuracy` option of the `accuracyAuthorization` settings then CleverTap Geofence will not work as expected since the app cannot reliably utilize Core Location's Region Monitoring APIs.

  An example of how an app can request location permission is below:

  ```
  // Swift
  let locationManager = CLLocationManager()
  locationManager.requestAlwaysAuthorization()

  // Objective-C 
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  [locationManager requestAlwaysAuthorization];
  ```


![Xcode Start Geofence Snippet](Docs/StartGeofence.png  "Example AppDelegate.swift")

## 📖 Customization
You can further *customize* your integration of CleverTap Geofence by following the [Customization document](Docs/Customization.md).

## 𝌡 Example Usage

- A [demo application](https://github.com/CleverTap/clevertap-geofence-ios/tree/master/Examples/CocoapodsExample) showing CocoaPods Installation.
- A [demo application](https://github.com/CleverTap/clevertap-geofence-ios/tree/master/Examples/CarthageExample) showing Carthage Installation.
- A [demo application](https://github.com/CleverTap/clevertap-geofence-ios/tree/master/Examples/Manual) showing Manual Installation.
- A [demo application](https://github.com/CleverTap/clevertap-geofence-ios/tree/master/Examples/SPMSample) showing SPM Installation.

## 🆕 Change Log

Refer to the [CleverTap Geofence SDK Change Log](https://github.com/CleverTap/clevertap-geofence-ios/blob/master/CHANGELOG.md).


## 🤝 Help and Questions

If you have questions or concerns, you can reach out to the CleverTap Support Team from your CleverTap Dashboard.

## 📄 License
CleverTap Geofence is MIT licensed, as found in the [LICENSE](https://github.com/CleverTap/clevertap-geofence-ios/blob/master/LICENSE) file.

