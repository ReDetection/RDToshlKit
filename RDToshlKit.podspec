#
# Be sure to run `pod lib lint RDToshlKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RDToshlKit"
  s.version          = "0.1.0"
  s.summary          = "A short description of RDToshlKit."
  s.description      = <<-DESC
                       An optional longer description of RDToshlKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/ReDetection/RDToshlKit"
  s.license          = 'MIT'
  s.author           = { "ReDetection" => "redetection@gmail.com" }
  s.source           = { :git => "https://github.com/ReDetection/RDToshlKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ReDetection'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation' #, 'MapKit'
  s.dependency 'RestKit', '~> 0.23.1'
  s.dependency 'AFOAuth2Client', '~> 0.1.2'
end
