
Pod::Spec.new do |s|
  s.name             = 'CleverTapGeofence'
  s.version          = '1.0.0'
  s.summary          = 'CleverTapGeofence provides Geofencing capabilities to CleverTap iOS SDK.'
  s.homepage         = 'https://github.com/CleverTap/clevertap-geofence-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "CleverTap" => "http://www.clevertap.com" }
  s.source           = { :git => 'https://github.com/CleverTap/clevertap-geofence-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/CleverTap'

  s.ios.framework         = 'CoreLocation'
  s.ios.deployment_target = '10.0'
  s.ios.dependency          'CleverTap-iOS-SDK', '~> 3.8'

  s.source_files    = 'Source/*'
  s.swift_version   = '5.1'
end
