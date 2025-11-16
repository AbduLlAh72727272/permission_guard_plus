Pod::Spec.new do |s|
  s.name             = 'permission_guard'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to request and guard permissions.'
  s.description      = <<-DESC
  permission_guard provides a simple API and widget to request
  and observe permission status on iOS and Android.
  DESC
  s.homepage         = 'https://example.com/permission_guard'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'YourOrg' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
