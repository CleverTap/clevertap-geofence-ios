
Pod::Spec.new do |s|
  s.name                   = 'CleverTap-Geofence-SDK'
  s.version                = '1.0.7'
  s.summary                = 'CleverTapGeofence provides Geofencing capabilities to CleverTap iOS SDK.'
  s.homepage               = 'https://github.com/CleverTap/clevertap-geofence-ios'
  s.license                = { :type => "MIT" }
  s.author                 = { "CleverTap" => "http://www.clevertap.com" }
  s.module_name            = 'CleverTapGeofence'
  s.source                 = { :git => 'https://github.com/CleverTap/clevertap-geofence-ios.git', :tag => s.version.to_s }
  s.social_media_url       = 'https://twitter.com/CleverTap'

  s.ios.framework          = 'CoreLocation'
  s.ios.deployment_target  = '10.0'
  s.ios.dependency         'CleverTap-iOS-SDK', '>= 3.9'
  s.resource_bundles       = {'CleverTapGeofence' => ['Sources/*.{xcprivacy}']}
  s.source_files           = 'Sources/*'
  s.swift_version          = '5.1'
  s.requires_arc           = true
end
