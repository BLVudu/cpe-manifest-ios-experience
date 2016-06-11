Pod::Spec.new do |s|

  s.name            = 'NextGen'
  s.version         = '0.0.1'
  s.summary         = 'UI for NextGen Experience'
  s.license         = 'Apache License, Version 2.0'
  s.homepage        = 'https://bitbucket.org/wbdigital/nextgen-ios'
  s.author          = { 'Alec Ananian' => 'alec.ananian@warnerbros.com' }

  s.platform        = :ios, '8.0'

  s.dependency        'NextGenDataManager', '~> 0.0.4'
  s.dependency        'MBProgressHUD', '~> 0.9.2'
  #s.dependency        'GoogleMaps', '~> 1.13.0'

  s.source          = { :git => 'https://bitbucket.org/wbdigital/nextgen-ios.git', :tag => s.version.to_s }
  s.source_files    = 'NextGen/**/*.swift', 'NextGen/*.swift'
  s.resources       = 'NextGen/*.lproj', 'NextGen/XIBs/*.xib', 'NextGen/Resources/**/*' 

end