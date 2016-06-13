Pod::Spec.new do |s|

  s.name            = 'NextGen'
  s.version         = '0.0.2'
  s.summary         = 'iOS User Experience for Cross-Platform Extras'
  s.license         = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.homepage        = 'https://github.com/warnerbros/cpe-manifest-ios-experience'
  s.author          = { 'Alec Ananian' => 'alec.ananian@warnerbros.com' }

  s.platform        = :ios, '8.0'

  s.dependency        'NextGenDataManager', '~> 1.0.0'
  s.dependency        'MBProgressHUD', '~> 0.9.2'

  s.source          = { :git => 'https://github.com/warnerbros/cpe-manifest-ios-experience.git', :tag => s.version.to_s }
  s.source_files    = 'NextGen/**/*.swift', 'NextGen/*.swift'
  s.resources       = 'NextGen/*.lproj', 'NextGen/XIBs/*.xib', 'NextGen/Resources/**/*'

  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

  # GoogleMaps.framework
  s.vendored_frameworks = 'Dependencies/GoogleMaps.framework'
  s.frameworks      = 'Accelerate', 'AVFoundation', 'CoreBluetooth', 'CoreData', 'CoreLocation', 'CoreText', 'GLKit', 'ImageIO', 'OpenGLES', 'QuartzCore', 'Security', 'SystemConfiguration', 'CoreGraphics'
  s.libraries       = 'icucore', 'c++', 'z'

end