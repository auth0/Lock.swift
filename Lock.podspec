if not defined? LOCK_VERSION
  LOCK_VERSION = File.read('Pod/version')
end

Pod::Spec.new do |s|
  s.name             = "Lock"
  s.version          = "#{LOCK_VERSION}"
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
  s.dependency 'CocoaLumberjack', '~> 2.0'
  s.default_subspecs = 'UI', 'Core', 'WebView'
  s.prefix_header_contents = <<-EOS
    #import "A0Logging.h"
    #define A0CurrentLockVersion @"#{LOCK_VERSION}"
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

  s.subspec 'CoreUI' do |coreui|
    coreui.platform = :ios
    coreui.public_header_files = 'Pod/Classes/CoreUI/*.h'
    coreui.source_files = ['Pod/Classes/CoreUI/*.{h,m}']
    coreui.dependency 'Lock/Core'
  end

  s.subspec 'UI' do |ui|
    ui.platform = :ios
    ui.public_header_files = 'Pod/Classes/UI/*.h'
    ui.private_header_files = ['Pod/Classes/UI/Private/*.h', 'Pod/Classes/Utils/*.h']
    ui.source_files = ['Pod/Classes/{UI,Utils}/*.{h,m}', 'Pod/Classes/UI/Private/*.{h,m}']
    ui.dependency 'Lock/CoreUI'
    ui.resources = 'Pod/Assets/UI/*.xib'
    ui.resource_bundles = { 'Auth0' => ['Pod/Assets/UI/Images/*.png', 'Pod/Assets/UI/*.plist', 'Pod/Assets/UI/*.ttf']}
  end

  s.subspec 'TouchID' do |touchid|
    touchid.platform = :ios
    touchid.public_header_files = 'Pod/Classes/TouchID/*.h'
    touchid.private_header_files = 'Pod/Classes/TouchID/Private/*.h'
    touchid.source_files = 'Pod/Classes/TouchID/**/*.{h,m}'
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

  s.subspec 'Email' do |email|
    email.platform = :ios
    email.public_header_files = 'Pod/Classes/Email/*.h'
    email.private_header_files = 'Pod/Classes/Email/Private/*.h'
    email.source_files = ['Pod/Classes/Email/*.{h,m}', 'Pod/Classes/Email/Private/*.{h,m}']
    email.resources = 'Pod/Assets/Email/*.xib'
    email.dependency 'Lock/UI'
    email.resource_bundles = { 'Auth0.Email' => ['Pod/Assets/Email/*.plist', 'Pod/Assets/Email/Images/*.png'] }
  end

  s.subspec '1Password' do |onepassword|
    onepassword.platform = :ios
    onepassword.public_header_files = 'Pod/Classes/1Password/*.h'
    onepassword.source_files = 'Pod/Classes/1Password/*.{h,m}'
    onepassword.dependency '1PasswordExtension', '~> 1.2'
    onepassword.dependency 'Lock/Core'
  end

  s.subspec 'Safari' do |safari|
    safari.platform = :ios
    safari.public_header_files = 'Pod/Classes/Safari/*.h'
    safari.source_files = 'Pod/Classes/Safari/*.{h,m}'
    safari.dependency 'Lock/Core'
  end

  s.subspec 'WebView' do |webview|
    webview.platform = :ios
    webview.public_header_files = 'Pod/Classes/WebView/*.h'
    webview.source_files = 'Pod/Classes/WebView/*.{h,m}'
    webview.resources = 'Pod/Assets/WebView/*.xib'
    webview.dependency 'Lock/CoreUI'
  end
end
