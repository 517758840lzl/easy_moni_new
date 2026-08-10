#
# Stub pod — iOS 活体走 Apple Vision，不链真实 Google ML Kit（其依赖要求 iOS 15.5）。
# 仅满足 GeneratedPluginRegistrant 的符号，无实际检测能力。
#
Pod::Spec.new do |s|
  s.name             = 'google_mlkit_commons'
  s.version          = '0.11.1'
  s.summary          = 'Stub for google_mlkit_commons on iOS (Vision path).'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Easy Moni' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
