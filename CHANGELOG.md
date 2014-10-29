# Change Log
All notable changes to this project will be documented in this file.

## master

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