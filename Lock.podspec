# version = `agvtool mvers -terse1`.strip
version = '2.0.0-rc.2'
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
  s.authors          = { "Auth0" => "support@auth0.com" }, { "Hernan Zalazar" => "hernan@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Lock.iOS-OSX.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.ios.deployment_target = "9.0"

  s.requires_arc = true


  s.dependency 'Auth0', '~> 1.1'
  s.default_subspecs = 'Classic'

  s.subspec 'Classic' do |classic|
    classic.ios.source_files = "Lock/**/*.swift"
    classic.ios.resource = ["Lock/*.xcassets", "Lock/*.lproj"]
  end

end