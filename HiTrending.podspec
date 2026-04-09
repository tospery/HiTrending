Pod::Spec.new do |s|
  s.name             = 'HiTrending'
  s.version          = '1.0.0'
  s.summary          = 'Github Trending API.'
  s.description      = <<-DESC
						Github Trending API using Swift.
                       DESC
  s.homepage         = 'https://github.com/tospery/HiTrending'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YangJianxiang' => 'tospery@gmail.com' }
  s.source           = { :git => 'https://github.com/tospery/HiTrending.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = '5.3'
  s.ios.deployment_target = '16.0'
  s.frameworks = 'Foundation'
  
  s.source_files = 'HiTrending/**/*'
  s.dependency 'HiBase', '~> 1.0'
  s.dependency 'SwiftSoup', '~> 2.7'
  
end
