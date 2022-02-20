#
# Be sure to run `pod lib lint MMFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMFoundation'
  s.version          = '0.1.0'
  s.summary          = 'iOS开发基础库封装'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 不断完善中，持续封装开发过程中遇到的功能
                       DESC

  s.homepage         = 'https://github.com/mingledev/MMFoundation.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mingle' => 'ggydm@vip.qq.com' }
  s.source           = { :git => 'https://github.com/mingledev/MMFoundation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'MMFoundation/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MMFoundation' => ['MMFoundation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'FMDB', '~> 2.7.5'
end
