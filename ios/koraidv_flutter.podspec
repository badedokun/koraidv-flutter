Pod::Spec.new do |s|
  s.name             = 'koraidv_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Kora IDV Identity Verification SDK for Flutter (iOS)'
  s.description      = <<-DESC
Flutter plugin wrapping the KoraIDV native iOS SDK via platform channels.
All camera, ML, liveness, and API logic stays in the native layer.
                       DESC
  s.homepage         = 'https://github.com/koraidv/koraidv-flutter'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Kora IDV' => 'support@koraidv.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.swift'

  s.platforms        = { :ios => '14.0' }
  s.swift_version    = '5.7'

  s.dependency 'Flutter'
  s.dependency 'KoraIDV', '~> 1.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
