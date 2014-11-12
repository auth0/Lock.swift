Pod::Spec.new do |s|
  s.name             = "Lock"
  s.version          = "1.4.0"
  s.summary          = "A library that uses Auth0 for Authentication with Native Look & Feel"
  s.description      = <<-DESC
[![Auth0](https://i.cloudup.com/1vaSVATKTL.png)](http://auth0.com)

Auth0 is a SaaS that helps you with Authentication and Authorization. You can use Social Providers (Like Facebook, Google, Twitter, etc.), Enterprise Providers (Active Directory, LDap, Windows Azure AD, SAML, etc.) and a Username/Password store which can be saved either by us or by you. We have SDKs for the most common platforms (Ruby, Node, iOS, Angular, etc.) so that with a couple lines of code, you can get the Authentication for your app implemented. Let us worry about Authentication so that you can focus on the core of your business.
                       DESC
  s.homepage         = "https://github.com/auth0/Lock.iOS-OSX"
  s.license          = 'MIT'
  s.authors          = { "Martin Gontovnikas" => "gonto@auth0.com" }, { "Hernan Zalazar" => "hernan@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Lock.iOS-OSX.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"

  s.requires_arc = true

  s.public_header_files = 'Pod/Classes/Lock.h'
  s.source_files = 'Pod/Classes/Lock.h'
  s.dependency 'libextobjc', '~> 0.4'
  s.dependency 'CocoaLumberjack', '~> 1.9'
  s.dependency 'ObjectiveSugar', '~> 1.1'
  s.default_subspecs = 'UI', 'Facebook', 'Twitter', 'Core'
  s.prefix_header_contents = <<-EOS
    #import "A0Logging.h"
    #define A0LocalizedString(key) NSLocalizedStringFromTable(key, @"Lock", nil)
  EOS

  s.subspec 'Core' do |core|
    core.public_header_files = ['Pod/Classes/Core/*.h']
    core.source_files = ['Pod/Classes/Core/*.{h,m}']
    core.ios.public_header_files = ['Pod/Classes/Core/iOS/*.h', 'Pod/Classes/Provider/*.h']
    core.osx.public_header_files = ['Pod/Classes/Core/OSX/*.h']
    core.ios.source_files = ['Pod/Classes/Core/iOS/*.{h,m}', 'Pod/Classes/Provider/*.{h,m}']
    core.osx.source_files = ['Pod/Classes/Core/OSX/*.{h,m}']
    core.dependency 'AFNetworking', '~> 2.3'
    core.dependency 'ISO8601DateFormatter', '~> 0.7'
  end

  s.subspec 'UI' do |ui|
    ui.platform = :ios
    ui.public_header_files = 'Pod/Classes/UI/*.h'
    ui.private_header_files = ['Pod/Classes/UI/Private/*.h', 'Pod/Classes/Utils/*.h']
    ui.source_files = ['Pod/Classes/{UI,Utils}/*.{h,m}', 'Pod/Classes/UI/Private/*.{h,m}']
    ui.dependency 'Lock/Core'
    ui.resources = 'Pod/Assets/*.xib'
    ui.resource_bundles = { 'Auth0' => ['Pod/Assets/Images/*.png', 'Pod/Assets/*.plist', 'Pod/Assets/*.ttf']}
  end

  s.subspec 'Facebook' do |facebook|
    facebook.platform = :ios
    facebook.public_header_files = 'Pod/Classes/Provider/Facebook/*.h'
    facebook.source_files = 'Pod/Classes/Provider/Facebook/*.{h,m}'
    facebook.dependency 'Lock/Core'
    facebook.dependency 'Facebook-iOS-SDK', '~> 3.15'
  end

  s.subspec 'Twitter' do |twitter|
    twitter.platform = :ios
    twitter.public_header_files = 'Pod/Classes/Twitter/*.h'
    twitter.source_files = 'Pod/Classes/Provider/Twitter/*.{h,m}'
    twitter.dependency 'Lock/Core'
    twitter.dependency 'BDBOAuth1Manager', '~> 1.3'
    twitter.dependency 'TWReverseAuth', '~> 0.1.0'
    twitter.dependency 'PSAlertView', '~> 2.0'
    twitter.frameworks  = 'Social', 'Accounts', 'Twitter'
  end

  s.subspec 'TouchID' do |touchid|
    touchid.platform = :ios
    touchid.public_header_files = 'Pod/Classes/TouchID/*.h'
    touchid.source_files = 'Pod/Classes/TouchID/*.{h,m}'
    touchid.resources = 'Pod/Assets/TouchID/*.xib'
    touchid.dependency 'Lock/UI'
    touchid.dependency 'TouchIDAuth', '~> 0.1'
  end

  s.subspec 'SMS' do |sms|
    sms.platform = :ios
    sms.public_header_files = 'Pod/Classes/SMS/*.h'
    sms.private_header_files = 'Pod/Classes/SMS/Private/*.h'
    sms.source_files = ['Pod/Classes/SMS/*.{h,m}', 'Pod/Classes/SMS/Private/*.{h,m}']
    sms.resources = 'Pod/Assets/SMS/*.xib'
    sms.dependency 'Lock/UI'
  end

end
