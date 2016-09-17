version = `agvtool mvers -terse1`.strip

Pod::Spec.new do |s|
  s.name             = "Lock"
  s.version          = version
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


  s.default_subspecs = 'UI', 'Core', 'WebView'
  s.prefix_header_contents = <<-EOS
    #define A0CurrentLockVersion @"#{version}"
  EOS

  s.subspec 'Core' do |core|
    core.public_header_files = ['Lock/Core/*.h', 'CocoaPods/Lock.h']
    core.private_header_files = ['Lock/Core/Private/*.h']
    core.source_files = ['Lock/Core/*.{h,m}', 'Lock/Core/Private/*.{h,m}', 'CocoaPods/Lock.h']
    core.ios.public_header_files = ['Lock/Core/iOS/*.h', 'Lock/Provider/*.h']
    core.osx.public_header_files = ['Lock/Core/OSX/*.h', 'Lock/Provider/*.h']
    core.ios.source_files = ['Lock/Core/iOS/*.{h,m}', 'Lock/Provider/*.{h,m}', 'Lock/Provider/Private/*.{h,m}']
    core.osx.source_files = ['Lock/Core/OSX/*.{h,m}', 'Lock/Provider/*.{h,m}', 'Lock/Provider/Private/*.{h,m}']
    core.dependency 'AFNetworking', '~> 3.0'
  end

  s.subspec 'CoreUI' do |coreui|
    coreui.platform = :ios
    coreui.public_header_files = 'Lock/CoreUI/*.h'
    coreui.source_files = ['Lock/CoreUI/*.{h,m}']
    coreui.dependency 'Lock/Core'
    coreui.dependency 'Masonry', '~> 0.6'
  end

  s.subspec 'UI' do |ui|
    ui.platform = :ios
    ui.public_header_files = 'Lock/UI/*.h'
    ui.private_header_files = ['Lock/UI/Private/*.h', 'Lock/Utils/*.h']
    ui.source_files = ['Lock/{UI,Utils}/*.{h,m}', 'Lock/UI/Private/*.{h,m}']
    ui.dependency 'Lock/CoreUI'
    ui.resource_bundles = { 'Auth0' => ['Auth0/Images/*.png', 'Auth0/Social/*.png', 'Auth0/*.plist'] }
  end

  s.subspec 'TouchID' do |touchid|
    touchid.platform = :ios
    touchid.public_header_files = 'Lock/TouchID/*.h'
    touchid.private_header_files = 'Lock/TouchID/Private/*.h'
    touchid.source_files = 'Lock/TouchID/**/*.{h,m}'
    touchid.dependency 'Lock/UI'
    touchid.dependency 'SimpleKeychain', '~> 0.2'
    touchid.dependency 'TouchIDAuth', '~> 0.1'
  end

  s.subspec 'SMS' do |sms|
    sms.platform = :ios
    sms.public_header_files = 'Lock/SMS/*.h'
    sms.private_header_files = 'Lock/SMS/Private/*.h'
    sms.source_files = ['Lock/SMS/*.{h,m}', 'Lock/SMS/Private/*.{h,m}']
    sms.dependency 'Lock/UI'
  end

  s.subspec 'Email' do |email|
    email.platform = :ios
    email.public_header_files = 'Lock/Email/*.h'
    email.private_header_files = 'Lock/Email/Private/*.h'
    email.source_files = ['Lock/Email/*.{h,m}', 'Lock/Email/Private/*.{h,m}']
    email.dependency 'Lock/UI'
  end

  s.subspec 'Safari' do |safari|
    safari.platform = :ios
    safari.public_header_files = 'Lock/Safari/*.h'
    safari.source_files = 'Lock/Safari/*.{h,m}'
    safari.dependency 'Lock/CoreUI'
  end

  s.subspec 'WebView' do |webview|
    webview.platform = :ios
    webview.public_header_files = 'Lock/WebView/*.h'
    webview.source_files = 'Lock/WebView/*.{h,m}'
    webview.dependency 'Lock/CoreUI'
    webview.frameworks = ["WebKit"]
  end
end
