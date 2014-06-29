Pod::Spec.new do |s|
  s.name     = 'Auth0Client'
  s.version  = '0.0.10'
  s.license  = 'MIT'
  s.summary  = 'A Cocoa Touch Static Library for authenticating users with the Auth0 platform.'
  s.homepage = 'https://github.com/auth0/Auth0.iOS'
  s.author  = "Auth0"
  s.source   = { :git => 'https://github.com/auth0/Auth0.iOS.git', :tag => "0.0.10" }
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.public_header_files = 'Auth0Client/*.h'
  s.source_files = 'Auth0Client/Auth0Client.{h,m}', 'Auth0Client/Auth0User.{h,m}', 'Auth0Client/Auth0WebViewController.{h,m}'

end
