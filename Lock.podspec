Pod::Spec.new do |s|
  s.name             = "Lock"
  s.version          = "1.12.0"
  s.summary          = "A library that uses Auth0 for Authentication with Native Look & Feel"
  s.description      = <<-DESC
[![Auth0](https://i.cloudup.com/1vaSVATKTL.png)](http://auth0.com)

Auth0 is a SaaS that helps you with Authentication and Authorization. You can use Social Providers (Like Facebook, Google, Twitter, etc.), Enterprise Providers (Active Directory, LDap, Windows Azure AD, SAML, etc.) and a Username/Password store which can be saved either by us or by you. We have SDKs for the most common platforms (Ruby, Node, iOS, Angular, etc.) so that with a couple lines of code, you can get the Authentication for your app implemented. Let us worry about Authentication so that you can focus on the core of your business.
                       DESC
  s.homepage         = "https://github.com/auth0/Lock.iOS-OSX"
  s.license          = 'MIT'
  s.authors          = { "Auth0" => "support@auth0.com" }, { "Hernan Zalazar" => "hernan@auth0.com" }, { "Martin Gontovnikas" => "gonto@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Lock.iOS-OSX.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"

  s.requires_arc = true

  s.dependency 'libextobjc', '~> 0.4'
  s.dependency 'CocoaLumberjack', '~> 2.0.0-rc'
  s.default_subspecs = 'UI', 'Core'
  s.prefix_header_contents = <<-EOS
    #import "A0Logging.h"
    #define A0LocalizedString(key) NSLocalizedStringFromTable(key, @"Lock", nil)
  EOS

  s.subspec 'Core' do |core|
    core.public_header_files = ['Pod/Classes/Core/*.h', 'Pod/Classes/Lock.h']
    core.private_header_files = ['Pod/Classes/Core/Private/*.h']
    core.source_files = ['Pod/Classes/Core/*.{h,m}', 'Pod/Classes/Core/Private/*.{h,m}', 'Pod/Classes/Lock.h']
    core.ios.public_header_files = ['Pod/Classes/Core/iOS/*.h', 'Pod/Classes/Provider/*.h']
    core.osx.public_header_files = ['Pod/Classes/Core/OSX/*.h']
    core.ios.source_files = ['Pod/Classes/Core/iOS/*.{h,m}', 'Pod/Classes/Provider/*.{h,m}']
    core.osx.source_files = ['Pod/Classes/Core/OSX/*.{h,m}']
    core.dependency 'AFNetworking', '~> 2.5'
    core.dependency 'ISO8601DateFormatter', '~> 0.7'
  end

  s.subspec 'ReactiveCore' do |core|
    core.public_header_files = ['Pod/Classes/ReactiveCore/*.h']
    core.source_files = ['Pod/Classes/ReactiveCore/*.{h,m}']
    core.dependency 'ReactiveCocoa', '~> 2.3'
    core.dependency 'Lock/Core'
  end

  s.subspec 'UI' do |ui|
    ui.platform = :ios
    ui.public_header_files = 'Pod/Classes/UI/*.h'
    ui.private_header_files = ['Pod/Classes/UI/Private/*.h', 'Pod/Classes/Utils/*.h']
    ui.source_files = ['Pod/Classes/{UI,Utils}/*.{h,m}', 'Pod/Classes/UI/Private/*.{h,m}']
    ui.dependency 'Lock/Core'
    ui.resources = 'Pod/Assets/UI/*.xib'
    ui.resource_bundles = { 'Auth0' => ['Pod/Assets/UI/Images/*.png', 'Pod/Assets/UI/*.plist', 'Pod/Assets/UI/*.ttf']}
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
    twitter.dependency 'BDBOAuth1Manager', '~> 1.5.0'
    twitter.dependency 'TWReverseAuth', '~> 0.1.0'
    twitter.dependency 'PSAlertView', '~> 2.0'
    twitter.frameworks  = 'Social', 'Accounts', 'Twitter'
  end

  s.subspec 'GooglePlus' do |gplus|
    gplus.platform = :ios
    gplus.public_header_files = 'Pod/Classes/Provider/GooglePlus/*.h'
    gplus.source_files = 'Pod/Classes/Provider/GooglePlus/*.{h,m}'
    gplus.dependency 'Lock/Core'
    gplus.dependency 'googleplus-ios-sdk', '~> 1.7.1'
  end

  s.subspec 'TouchID' do |touchid|
    touchid.platform = :ios
    touchid.public_header_files = 'Pod/Classes/TouchID/*.h'
    touchid.source_files = 'Pod/Classes/TouchID/*.{h,m}'
    touchid.resources = 'Pod/Assets/TouchID/*.xib'
    touchid.dependency 'Lock/UI'
    touchid.dependency 'SimpleKeychain', '~> 0.2'
    touchid.dependency 'TouchIDAuth', '~> 0.1'
    touchid.resource_bundles = { 'Auth0.TouchID' => ['Pod/Assets/TouchID/Images/*.png'] }
  end

  s.subspec 'SMS' do |sms|
    sms.platform = :ios
    sms.public_header_files = 'Pod/Classes/SMS/*.h'
    sms.private_header_files = 'Pod/Classes/SMS/Private/*.h'
    sms.source_files = ['Pod/Classes/SMS/*.{h,m}', 'Pod/Classes/SMS/Private/*.{h,m}']
    sms.resources = 'Pod/Assets/SMS/*.xib'
    sms.dependency 'Lock/UI'
    sms.resource_bundles = { 'Auth0.SMS' => ['Pod/Assets/SMS/*.plist', 'Pod/Assets/SMS/Images/*.png'] }
  end

  s.subspec '1Password' do |onepassword|
    onepassword.platform = :ios
    onepassword.public_header_files = 'Pod/Classes/1Password/*.h'
    onepassword.source_files = 'Pod/Classes/1Password/*.{h,m}'
    onepassword.dependency '1PasswordExtension', '~> 1.2'
    onepassword.dependency 'Lock/Core'
  end

end
