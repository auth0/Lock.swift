#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Auth0Client"
  s.version          = "0.1.0"
  s.summary          = "A library to connect with Auth0 services"
  s.description      = <<-DESC
                       An optional longer description of Auth0Client

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/auth0/Auth0.iOS"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.authors          = { "Eugenio Pace" => "eugeniop@auth0.com" }, { "Sebastian Iacomuzzi" => "iaco@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Auth0.iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/authzero'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*.xib'
  s.resource_bundles = { 'Auth0' => ['Pod/Assets/Images/*.png', 'Pod/Assets/*.plist']}

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.3'
end
