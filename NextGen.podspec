Pod::Spec.new do |s|

  s.name            = 'NextGen'
  s.version         = '0.0.1'
  s.summary         = 'iOS User Experience for Cross-Platform Extras'
  s.license         = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.homepage        = 'https://github.com/warnerbros/cpe-manifest-ios-experience'
  s.author          = { 'Alec Ananian' => 'alec.ananian@warnerbros.com' }

  s.platform        = :ios, '8.0'

  s.dependency        'NextGenDataManager', '~> 0.0.4'
  s.dependency        'MBProgressHUD', '~> 0.9.2'
  #s.dependency        'GoogleMaps', '~> 1.13.0'

  s.source          = { :git => 'https://github.com/warnerbros/cpe-manifest-ios-experience.git', :tag => s.version.to_s }
  s.source_files    = 'NextGen/**/*.swift', 'NextGen/*.swift'
  s.resources       = 'NextGen/*.lproj', 'NextGen/XIBs/*.xib', 'NextGen/Resources/**/*' 

end
