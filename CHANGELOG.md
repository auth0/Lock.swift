# Change Log
All notable changes to this project will be documented in this file.

## master
###Added
- SMS Authentication
- OSX Support (Only Core classes no UI or Social integration).
- 
###Changed
- Fixed styles of native widget
- Fixed issues and improved A0Theme

## 1.4.0 - 2014-11-11
###Changed
- Auth0.iOS is now Lock.
- Renamed `Auth0.h` to `Lock.h`.
- Renamed `A0TouchIDAuthenticationViewController` to `A0TouchIDLockViewController`.
- Renamed `A0AuthenticationViewController` to `A0LockViewController`.

## 1.3.0 - 2014-11-10
###Added
- TouchID Authentication 
- API Client for request using user's accessToken or idToken
- Added example for how to localize native screens.

###Changed
- Deprecated fetch profiles methods in `A0APIClient`
- Added missing Localized strings.

## 1.2.0 - 2014-10-29
###Added 
- `A0UserIdentity` now has a property `profileData` with profile info of the user in that Identity Provider.

## 1.1.0 - 2014-10-22
### Added
- Enterprise connection support
- iOS 8 Keyboard issue fix
- New methods to Refresh JWT token or obtain delegation token

### Changed
- Deprecated old delegation methods in `A0APIClient`

## 1.0.0 - 2014-10-06
### Added
- Native Widget `A0AuthenticationController` to authenticate with Database & Social connections.
- Native authentication with Facebook & Twitter
- Auth0 authentication API wrapper `A0APIClient`
- Authentication with Web Flow (for those connecitons without native integration). It can be using Safari or an embedded `UIWebView`.

### Changed
- All errors from API are returned as a NSError.
- User profile and token information are stored in custom objects instead of `NSDictionary`

### Removed
- `Auth0Client` and `UIWebView` widget is no longer available.
