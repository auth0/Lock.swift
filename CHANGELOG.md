# Change Log
All notable changes to this project will be documented in this file.

##master

###Added
- A new `UIViewController` to display Sign Up screen only: `A0LockSignUpViewController`
- Specify the Database connection that Lock should use by default.
- Google+ native integration.
- Enable/Disable dynamically Lock's logging using `A0LockLogger`.
- UINotifications for Login, SignUp, Change Password and Dismiss events

###Changed
- Deprecated `- (void)registerImageWithName:(NSString *)name forKey:(NSString *)key` of `A0Theme` in favor of `- (void)registerImageWithName:(NSString *)name bundle:(NSBundle *)bundle forKey:(NSString *)key;` to fix issue with assets bundled in iOS 8 Framework.

## 1.9.0 - 2015-02-27

###Added
- Filter application connections that Lock will use in runtime.
- Ability to customise primary and secondary buttons with images, and credential box background color.

## 1.8.0 - 2015-02-13

###Changed
- Fixed project structure to support Dynamic Framework instead of static lib
- Use NSURLSession instead of NSURLConnection for `A0APIClient` requests.
- Fix social connection small button sizes.
- Avoid default enterprise connection to override selected social connection.
 
## 1.7.0 - 2014-12-04

###Added
- On Premise API support.

###Changed
- UI improvements in UILockViewController.
- Fixed Theme for SMS & TouchID

## 1.6.1 - 2014-11-27

###Changed
- Show user already exists in TouchID login
- Disable Logging by default.

## 1.6.0 - 2014-11-26

###Changed
- Fixed issue with BDBOAuth1Manager pod
- Improved SMS Login screen
- Use Auth0 API v2 to send SMS code.

## 1.5.0 - 2014-11-25

###Added
- SMS Authentication (Beta).
- OSX Support (Only Core classes no UI or Social integration).
- 1Password extension support.
- `A0APIClient` has support for [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) with the subspec `ReactiveCore`.

###Changed
- Fixed styles of native widget
- Fixed issues and improved A0Theme
- Improved errors when network is unavailable.

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
