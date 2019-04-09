Pod::Spec.new do |s|
  s.name             = 'NextcloudConfig'
  s.version          = '0.1.0'
  s.summary          = 'Configuration from a nextcloud server.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/SMillerDev/NextcloudConfig'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sean Molenaar' => 'sean@seanmolenaar.eu' }
  s.source           = { :git => 'https://github.com/SMillerDev/NextcloudConfig.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version         = '5.0'
  s.source_files          = 'NextcloudConfig/Classes/**/*'
  s.frameworks            = 'Foundation'
end
