Pod::Spec.new do |s|
  s.name             = "Auth0Client"
  s.version          = "0.1.0"
  s.summary          = "A library to connect with Auth0 services"
  s.description      = <<-DESC
[![Auth0](https://i.cloudup.com/1vaSVATKTL.png)](http://auth0.com)

[Auth0](http://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Office365, Google Apps, Salesforce.

Auth0.iOS is a client-side library for [Auth0](http://auth0.com). It allows you to trigger the authentication process and parse the [JWT](http://openid.net/specs/draft-jones-json-web-token-07.html) (JSON web token) with just the Auth0 `clientID`. Once you have the JWT you can use it to authenticate requests to your http API and validate the JWT in your server-side logic with the `clientSecret`.
                       DESC
  s.homepage         = "https://github.com/auth0/Auth0.iOS"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.authors          = { "Eugenio Pace" => "eugeniop@auth0.com" }, { "Sebastian Iacomuzzi" => "iaco@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Auth0.iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/authzero'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.dependency 'libextobjc', '~> 0.4'
  s.dependency 'CocoaLumberjack', '~> 1.9'
  s.default_subspecs = 'UI', 'Facebook', 'Twitter'
  s.prefix_header_contents = <<-EOS
    #import "A0Logging.h"
    #define A0LocalizedString(key) NSLocalizedStringFromTable(key, @"Auth0", nil)
  EOS
  s.subspec 'Core' do |core|
    core.public_header_files = 'Pod/Classes/Core/*.h'
    core.source_files = 'Pod/Classes/Core/*.{h,m}'
    core.dependency 'AFNetworking', '~> 2.3'
    core.dependency 'ISO8601DateFormatter', '~> 0.7'
    core.dependency 'UICKeyChainStore', '~> 1.0.5'
  end

  s.subspec 'UI' do |ui|
    ui.public_header_files = 'Pod/Classes/{UI,Utils}/*.h'
    ui.source_files = 'Pod/Classes/{UI,Utils}/*.{h,m}'
    ui.dependency 'Auth0Client/Social'
    ui.resources = 'Pod/Assets/*.xib'
    ui.resource_bundles = { 'Auth0' => ['Pod/Assets/Images/*.png', 'Pod/Assets/*.plist', 'Pod/Assets/connections.ttf']}
  end

  s.subspec 'Social' do |social|
    social.public_header_files = 'Pod/Classes/Social/*.h'
    social.source_files = 'Pod/Classes/Social/*.{h,m}'
    social.dependency 'Auth0Client/Core'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.public_header_files = 'Pod/Classes/Facebook/*.h'
    facebook.source_files = 'Pod/Classes/Social/Facebook/*.{h,m}'
    facebook.dependency 'Auth0Client/Social'
    facebook.dependency 'Facebook-iOS-SDK', '~> 3.15'
  end

  s.subspec 'Twitter' do |twitter|
    twitter.public_header_files = 'Pod/Classes/Twitter/*.h'
    twitter.source_files = 'Pod/Classes/Social/Twitter/*.{h,m}'
    twitter.dependency 'Auth0Client/Social'
    twitter.dependency 'BDBOAuth1Manager', '~> 1.3'
    twitter.dependency 'TWReverseAuth', '~> 0.1.0'
    twitter.dependency 'PSAlertView', '~> 2.0'
    twitter.frameworks  = 'Social', 'Accounts', 'Twitter'
  end
end
