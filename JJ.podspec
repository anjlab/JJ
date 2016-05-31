#
# Be sure to run `pod lib lint JJ.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JJ'
  s.version          = '0.5.0'
  s.summary          = 'Super simple json parsing and NSCoder encoding and decoding.'

  s.description      = <<-DESC
Super simple json parser for Swift (may be 501 or more)
And more: simple tools for NSCoder
                       DESC

  s.homepage         = 'https://github.com/anjlab/JJ'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yury Korolev' => 'yury.korolev@gmail.com' }
  s.source           = { :git => 'https://github.com/anjlab/JJ.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/anjlab'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JJ/Classes/**/*'
end
