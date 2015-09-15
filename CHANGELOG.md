# Change Log

## [1.18.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.18.0) (2015-09-15)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.17.0...1.18.0)

**Fixed bugs:**

- fetchNewIdTokenWithRefreshToken is missing a parameter [\#162](https://github.com/auth0/Lock.iOS-OSX/issues/162)

**Merged pull requests:**

- Default api\_type for delegation [\#166](https://github.com/auth0/Lock.iOS-OSX/pull/166) ([hzalaz](https://github.com/hzalaz))

- Fix Xcode 7 warnings [\#165](https://github.com/auth0/Lock.iOS-OSX/pull/165) ([hzalaz](https://github.com/hzalaz))

## [1.17.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.17.0) (2015-08-11)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.16.1...1.17.0)

**Implemented enhancements:**

- Allow to change \(and localize\) "Cancel" button on WebView auth [\#152](https://github.com/auth0/Lock.iOS-OSX/issues/152)

- Handle network timeout for A0WebKitViewController [\#151](https://github.com/auth0/Lock.iOS-OSX/issues/151)

- Customize WKWebView based auth UI [\#149](https://github.com/auth0/Lock.iOS-OSX/issues/149)

**Fixed bugs:**

- Username field does not inherit A0ThemeTextFieldTextColor [\#148](https://github.com/auth0/Lock.iOS-OSX/issues/148)

**Merged pull requests:**

- Refactor UI Subspec [\#157](https://github.com/auth0/Lock.iOS-OSX/pull/157) ([hzalaz](https://github.com/hzalaz))

- Fix how Safari integration handles connection name [\#156](https://github.com/auth0/Lock.iOS-OSX/pull/156) ([hzalaz](https://github.com/hzalaz))

- Apply theme to username field in Sign Up [\#155](https://github.com/auth0/Lock.iOS-OSX/pull/155) ([hzalaz](https://github.com/hzalaz))

- Avoid leaking NSURLSession [\#154](https://github.com/auth0/Lock.iOS-OSX/pull/154) ([hzalaz](https://github.com/hzalaz))

- Improve A0WebKitViewController UI and customisation options [\#153](https://github.com/auth0/Lock.iOS-OSX/pull/153) ([hzalaz](https://github.com/hzalaz))

- Improve how API errors are handled [\#150](https://github.com/auth0/Lock.iOS-OSX/pull/150) ([hzalaz](https://github.com/hzalaz))

- Add detail to SignUp failure dialog [\#147](https://github.com/auth0/Lock.iOS-OSX/pull/147) ([brandonecraig](https://github.com/brandonecraig))

## [1.16.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.16.1) (2015-07-23)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.16.0...1.16.1)

**Implemented enhancements:**

- Option to use WKWebView [\#64](https://github.com/auth0/Lock.iOS-OSX/issues/64)

**Fixed bugs:**

- Fix signature for signup with email method [\#144](https://github.com/auth0/Lock.iOS-OSX/issues/144)

- When app supports landscape Lock is displayed landscape [\#142](https://github.com/auth0/Lock.iOS-OSX/issues/142)

**Merged pull requests:**

- Fix wrong type of callback in signup [\#146](https://github.com/auth0/Lock.iOS-OSX/pull/146) ([hzalaz](https://github.com/hzalaz))

- Fix subscript support in Swift for A0AuthParameters [\#145](https://github.com/auth0/Lock.iOS-OSX/pull/145) ([hzalaz](https://github.com/hzalaz))

- Force all views that have autorotate disabled to portrait orientation. [\#141](https://github.com/auth0/Lock.iOS-OSX/pull/141) ([basejumper9](https://github.com/basejumper9))

## [1.16.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.16.0) (2015-07-20)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.15.1...1.16.0)

**Merged pull requests:**

- Remove deprecated native integrations [\#140](https://github.com/auth0/Lock.iOS-OSX/pull/140) ([hzalaz](https://github.com/hzalaz))

- Use WKWebView for web flow authentication [\#139](https://github.com/auth0/Lock.iOS-OSX/pull/139) ([hzalaz](https://github.com/hzalaz))

## [1.15.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.15.1) (2015-07-18)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.15.0...1.15.1)

## [1.15.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.15.0) (2015-07-17)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.14.0...1.15.0)

**Merged pull requests:**

- WebView subspec [\#138](https://github.com/auth0/Lock.iOS-OSX/pull/138) ([hzalaz](https://github.com/hzalaz))

- WebView Authenticator for IdP [\#137](https://github.com/auth0/Lock.iOS-OSX/pull/137) ([hzalaz](https://github.com/hzalaz))

- Move Safari based auth classes to a subpsec [\#136](https://github.com/auth0/Lock.iOS-OSX/pull/136) ([hzalaz](https://github.com/hzalaz))

- Feature usewebview as default [\#135](https://github.com/auth0/Lock.iOS-OSX/pull/135) ([hzalaz](https://github.com/hzalaz))

## [1.14.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.14.0) (2015-07-10)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.13.0...1.14.0)

**Implemented enhancements:**

- Show errors returned from Rules [\#119](https://github.com/auth0/Lock.iOS-OSX/issues/119)

**Closed issues:**

- Clean up warnings [\#127](https://github.com/auth0/Lock.iOS-OSX/issues/127)

**Merged pull requests:**

- Add nullability macros for better swift support [\#133](https://github.com/auth0/Lock.iOS-OSX/pull/133) ([hzalaz](https://github.com/hzalaz))

- Add methods to return user & app metadata from A0UserProfile [\#132](https://github.com/auth0/Lock.iOS-OSX/pull/132) ([hzalaz](https://github.com/hzalaz))

- Use passwordless endpoint [\#131](https://github.com/auth0/Lock.iOS-OSX/pull/131) ([hzalaz](https://github.com/hzalaz))

- Display error returned by a Auth0 rule [\#130](https://github.com/auth0/Lock.iOS-OSX/pull/130) ([hzalaz](https://github.com/hzalaz))

- Build issues & warnings [\#128](https://github.com/auth0/Lock.iOS-OSX/pull/128) ([hzalaz](https://github.com/hzalaz))

## [1.13.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.13.0) (2015-05-26)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.12.1...1.13.0)

**Implemented enhancements:**

- Specify DB connection for TouchID [\#120](https://github.com/auth0/Lock.iOS-OSX/issues/120)

- Support disableSignupAction and disableChangePassword [\#114](https://github.com/auth0/Lock.iOS-OSX/issues/114)

- Add default headers with SDK version for API calls [\#102](https://github.com/auth0/Lock.iOS-OSX/issues/102)

**Fixed bugs:**

- Allow API v2 endpoint to be configurable [\#103](https://github.com/auth0/Lock.iOS-OSX/issues/103)

**Merged pull requests:**

- Use custom api domain instead of generic one [\#125](https://github.com/auth0/Lock.iOS-OSX/pull/125) ([hzalaz](https://github.com/hzalaz))

- Set default DB connection for TouchID authentication [\#124](https://github.com/auth0/Lock.iOS-OSX/pull/124) ([hzalaz](https://github.com/hzalaz))

- Auth0 client Header information [\#123](https://github.com/auth0/Lock.iOS-OSX/pull/123) ([hzalaz](https://github.com/hzalaz))

- Feature hide SignUp & Reset Password buttons [\#122](https://github.com/auth0/Lock.iOS-OSX/pull/122) ([hzalaz](https://github.com/hzalaz))

## [1.12.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.12.1) (2015-05-20)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.12.0...1.12.1)

**Implemented enhancements:**

- Update Facebook SDK [\#97](https://github.com/auth0/Lock.iOS-OSX/issues/97)

**Merged pull requests:**

- Fix issues when building as a Cocoa Touch Framework [\#121](https://github.com/auth0/Lock.iOS-OSX/pull/121) ([hzalaz](https://github.com/hzalaz))

## [1.12.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.12.0) (2015-05-19)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.11.3...1.12.0)

**Implemented enhancements:**

- Move social integrations to an independent pod [\#113](https://github.com/auth0/Lock.iOS-OSX/issues/113)

**Fixed bugs:**

- UITheme is using a iOS 8+ API [\#111](https://github.com/auth0/Lock.iOS-OSX/issues/111)

**Closed issues:**

- unlinkAccountWithUserId uses application client ID, but v1 /unlink API requires global\_client\_id [\#108](https://github.com/auth0/Lock.iOS-OSX/issues/108)

**Merged pull requests:**

- Deprecate social subspecs \(FB, G+ & Twitter\) [\#118](https://github.com/auth0/Lock.iOS-OSX/pull/118) ([hzalaz](https://github.com/hzalaz))

- Move FB native auth to a independent library [\#117](https://github.com/auth0/Lock.iOS-OSX/pull/117) ([hzalaz](https://github.com/hzalaz))

- Fix crash issue iOS 7 and placeholder text color [\#116](https://github.com/auth0/Lock.iOS-OSX/pull/116) ([hzalaz](https://github.com/hzalaz))

- Deprecate A0APIClient & A0IdentityProviderAuthenticator singletons [\#115](https://github.com/auth0/Lock.iOS-OSX/pull/115) ([hzalaz](https://github.com/hzalaz))

## [1.11.3](https://github.com/auth0/Lock.iOS-OSX/tree/1.11.3) (2015-05-11)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.11.2...1.11.3)

**Fixed bugs:**

- A0AuthParameters does not implement NSCopying properly [\#104](https://github.com/auth0/Lock.iOS-OSX/issues/104)

- SignUp disclaimer view is not displayed [\#99](https://github.com/auth0/Lock.iOS-OSX/issues/99)

**Merged pull requests:**

- Fix unlink account in A0APIClient [\#110](https://github.com/auth0/Lock.iOS-OSX/pull/110) ([hzalaz](https://github.com/hzalaz))

- Fix issue with A0AuthParameter copy method [\#109](https://github.com/auth0/Lock.iOS-OSX/pull/109) ([hzalaz](https://github.com/hzalaz))

- Introduce A0Lock class [\#107](https://github.com/auth0/Lock.iOS-OSX/pull/107) ([hzalaz](https://github.com/hzalaz))

## [1.11.2](https://github.com/auth0/Lock.iOS-OSX/tree/1.11.2) (2015-05-05)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.11.1...1.11.2)

## [1.11.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.11.1) (2015-05-04)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.11.0...1.11.1)

**Closed issues:**

- Support for dynamic fwk [\#62](https://github.com/auth0/Lock.iOS-OSX/issues/62)

**Merged pull requests:**

- Fix custom disclaimer view layout. [\#100](https://github.com/auth0/Lock.iOS-OSX/pull/100) ([hzalaz](https://github.com/hzalaz))

## [1.11.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.11.0) (2015-04-23)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.5...1.11.0)

**Fixed bugs:**

- Support EU deployments [\#94](https://github.com/auth0/Lock.iOS-OSX/issues/94)

**Closed issues:**

- Native form for ADFS and WAAD connections [\#91](https://github.com/auth0/Lock.iOS-OSX/issues/91)

**Merged pull requests:**

- Use /ro with waad and adfs connections [\#96](https://github.com/auth0/Lock.iOS-OSX/pull/96) ([hzalaz](https://github.com/hzalaz))

- Pick EU cdn when using auth0 EU domain. [\#95](https://github.com/auth0/Lock.iOS-OSX/pull/95) ([hzalaz](https://github.com/hzalaz))

- Feature requires username [\#93](https://github.com/auth0/Lock.iOS-OSX/pull/93) ([hzalaz](https://github.com/hzalaz))

## [1.10.5](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.5) (2015-04-12)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.4...1.10.5)

## [1.10.4](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.4) (2015-04-08)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.3...1.10.4)

## [1.10.3](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.3) (2015-04-04)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.3.beta...1.10.3)

## [1.10.3.beta](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.3.beta) (2015-03-30)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.2...1.10.3.beta)

## [1.10.2](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.2) (2015-03-17)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.1...1.10.2)

**Merged pull requests:**

- Fix `connection\_scopes` issue [\#90](https://github.com/auth0/Lock.iOS-OSX/pull/90) ([hzalaz](https://github.com/hzalaz))

## [1.10.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.1) (2015-03-16)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.10.0...1.10.1)

**Merged pull requests:**

- Add extra method to call social auth with strategy name. [\#89](https://github.com/auth0/Lock.iOS-OSX/pull/89) ([hzalaz](https://github.com/hzalaz))

- Fix issue that makes Google+ progress indicator stays forever [\#88](https://github.com/auth0/Lock.iOS-OSX/pull/88) ([hzalaz](https://github.com/hzalaz))

- Theme improvements [\#87](https://github.com/auth0/Lock.iOS-OSX/pull/87) ([hzalaz](https://github.com/hzalaz))

- Default DB connection fix [\#86](https://github.com/auth0/Lock.iOS-OSX/pull/86) ([hzalaz](https://github.com/hzalaz))

## [1.10.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.10.0) (2015-03-06)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.9.0...1.10.0)

**Implemented enhancements:**

- Logging improvements [\#68](https://github.com/auth0/Lock.iOS-OSX/issues/68)

**Closed issues:**

- Post a NSNotification for important Lock events [\#82](https://github.com/auth0/Lock.iOS-OSX/issues/82)

- Call callback on successful/failed Reset Password [\#37](https://github.com/auth0/Lock.iOS-OSX/issues/37)

**Merged pull requests:**

- Fix issue for images in a theme when Lock is bundled as iOS 8 framework. [\#84](https://github.com/auth0/Lock.iOS-OSX/pull/84) ([hzalaz](https://github.com/hzalaz))

- Lock Notifications [\#83](https://github.com/auth0/Lock.iOS-OSX/pull/83) ([hzalaz](https://github.com/hzalaz))

- Dynamic Logging [\#81](https://github.com/auth0/Lock.iOS-OSX/pull/81) ([hzalaz](https://github.com/hzalaz))

- Google+ Native integration [\#80](https://github.com/auth0/Lock.iOS-OSX/pull/80) ([hzalaz](https://github.com/hzalaz))

- Specify default DB connection [\#79](https://github.com/auth0/Lock.iOS-OSX/pull/79) ([hzalaz](https://github.com/hzalaz))

- Standalone UIViewController for Sign Up [\#78](https://github.com/auth0/Lock.iOS-OSX/pull/78) ([hzalaz](https://github.com/hzalaz))

## [1.9.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.9.0) (2015-02-28)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.8.0...1.9.0)

**Implemented enhancements:**

- New customisation keys for A0Theme [\#74](https://github.com/auth0/Lock.iOS-OSX/issues/74)

- Select what connections to use in Lock [\#72](https://github.com/auth0/Lock.iOS-OSX/issues/72)

**Fixed bugs:**

- Primary button title color cannot be changed using A0Theme [\#73](https://github.com/auth0/Lock.iOS-OSX/issues/73)

**Merged pull requests:**

- A0Theme improvements [\#77](https://github.com/auth0/Lock.iOS-OSX/pull/77) ([hzalaz](https://github.com/hzalaz))

- Allow customisation of Primary Button text color [\#76](https://github.com/auth0/Lock.iOS-OSX/pull/76) ([hzalaz](https://github.com/hzalaz))

- Filter enabled connections [\#75](https://github.com/auth0/Lock.iOS-OSX/pull/75) ([hzalaz](https://github.com/hzalaz))

## [1.8.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.8.0) (2015-02-13)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.7.1...1.8.0)

**Merged pull requests:**

- Use NSURLSession with AFNetworking [\#71](https://github.com/auth0/Lock.iOS-OSX/pull/71) ([hzalaz](https://github.com/hzalaz))

- Enterprise+Social screen issues [\#70](https://github.com/auth0/Lock.iOS-OSX/pull/70) ([hzalaz](https://github.com/hzalaz))

- Added cognito example :\). [\#67](https://github.com/auth0/Lock.iOS-OSX/pull/67) ([mgonto](https://github.com/mgonto))

- Dynamic FKW support [\#66](https://github.com/auth0/Lock.iOS-OSX/pull/66) ([hzalaz](https://github.com/hzalaz))

## [1.7.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.7.1) (2014-12-16)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.7.0...1.7.1)

**Merged pull requests:**

- Social only layout height is zero [\#61](https://github.com/auth0/Lock.iOS-OSX/pull/61) ([hzalaz](https://github.com/hzalaz))

## [1.7.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.7.0) (2014-12-04)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.6.1...1.7.0)

**Merged pull requests:**

- Theming improvements & Example Theme [\#60](https://github.com/auth0/Lock.iOS-OSX/pull/60) ([hzalaz](https://github.com/hzalaz))

- Support for on premise API. [\#59](https://github.com/auth0/Lock.iOS-OSX/pull/59) ([hzalaz](https://github.com/hzalaz))

- README update [\#58](https://github.com/auth0/Lock.iOS-OSX/pull/58) ([hzalaz](https://github.com/hzalaz))

- Lock Full Login layout changes [\#57](https://github.com/auth0/Lock.iOS-OSX/pull/57) ([hzalaz](https://github.com/hzalaz))

## [1.6.1](https://github.com/auth0/Lock.iOS-OSX/tree/1.6.1) (2014-11-27)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.6.0...1.6.1)

## [1.6.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.6.0) (2014-11-26)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.5.0...1.6.0)

**Merged pull requests:**

- SMS VC enhancements [\#56](https://github.com/auth0/Lock.iOS-OSX/pull/56) ([hzalaz](https://github.com/hzalaz))

- SMS API v2 [\#55](https://github.com/auth0/Lock.iOS-OSX/pull/55) ([hzalaz](https://github.com/hzalaz))

- Updated the lock.podspec and podfile.lock [\#54](https://github.com/auth0/Lock.iOS-OSX/pull/54) ([RealBrubru](https://github.com/RealBrubru))

- Update A0TwitterAuthenticator.m [\#53](https://github.com/auth0/Lock.iOS-OSX/pull/53) ([RealBrubru](https://github.com/RealBrubru))

## [1.5.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.5.0) (2014-11-25)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.4.0...1.5.0)

**Closed issues:**

- Issue building Auth0.iOS [\#34](https://github.com/auth0/Lock.iOS-OSX/issues/34)

**Merged pull requests:**

- Network status [\#52](https://github.com/auth0/Lock.iOS-OSX/pull/52) ([hzalaz](https://github.com/hzalaz))

- AWS Sample [\#51](https://github.com/auth0/Lock.iOS-OSX/pull/51) ([hzalaz](https://github.com/hzalaz))

- Firebase delegation example. [\#50](https://github.com/auth0/Lock.iOS-OSX/pull/50) ([hzalaz](https://github.com/hzalaz))

- ReactiveCocoa for API Client [\#49](https://github.com/auth0/Lock.iOS-OSX/pull/49) ([hzalaz](https://github.com/hzalaz))

- 1Password integration [\#48](https://github.com/auth0/Lock.iOS-OSX/pull/48) ([hzalaz](https://github.com/hzalaz))

- SMS Login  [\#47](https://github.com/auth0/Lock.iOS-OSX/pull/47) ([hzalaz](https://github.com/hzalaz))

- Native widgets styles [\#46](https://github.com/auth0/Lock.iOS-OSX/pull/46) ([hzalaz](https://github.com/hzalaz))

## [1.4.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.4.0) (2014-11-11)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.3.0...1.4.0)

**Merged pull requests:**

- Rename to Lock for iOS/OSX [\#45](https://github.com/auth0/Lock.iOS-OSX/pull/45) ([hzalaz](https://github.com/hzalaz))

## [1.3.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.3.0) (2014-11-11)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.2.0...1.3.0)

**Implemented enhancements:**

- Suggestion: Add default parameters to fetchDelegationTokenWithParameters  [\#41](https://github.com/auth0/Lock.iOS-OSX/issues/41)

**Merged pull requests:**

- Localization enhancements [\#44](https://github.com/auth0/Lock.iOS-OSX/pull/44) ([hzalaz](https://github.com/hzalaz))

- Add default values for fetch delegation methods. [\#43](https://github.com/auth0/Lock.iOS-OSX/pull/43) ([hzalaz](https://github.com/hzalaz))

- TouchID Authentication [\#42](https://github.com/auth0/Lock.iOS-OSX/pull/42) ([hzalaz](https://github.com/hzalaz))

## [1.2.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.2.0) (2014-10-29)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.1.0...1.2.0)

**Merged pull requests:**

- Handle delegation call [\#39](https://github.com/auth0/Lock.iOS-OSX/pull/39) ([iellis](https://github.com/iellis))

## [1.1.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.1.0) (2014-10-22)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.0.0...1.1.0)

**Implemented enhancements:**

- Implementent Enterprise Connections [\#32](https://github.com/auth0/Lock.iOS-OSX/issues/32)

- Add Account Linking [\#27](https://github.com/auth0/Lock.iOS-OSX/issues/27)

**Closed issues:**

- Delegation not functional / crashes [\#38](https://github.com/auth0/Lock.iOS-OSX/issues/38)

- Integrate with the Linkedin native application instead of webview [\#20](https://github.com/auth0/Lock.iOS-OSX/issues/20)

**Merged pull requests:**

- Fix issue with Delegated Auth response payload [\#40](https://github.com/auth0/Lock.iOS-OSX/pull/40) ([hzalaz](https://github.com/hzalaz))

- Enterprise Authentication [\#35](https://github.com/auth0/Lock.iOS-OSX/pull/35) ([hzalaz](https://github.com/hzalaz))

- Multiple connections per Strategy. [\#33](https://github.com/auth0/Lock.iOS-OSX/pull/33) ([hzalaz](https://github.com/hzalaz))

- Feature link account [\#31](https://github.com/auth0/Lock.iOS-OSX/pull/31) ([hzalaz](https://github.com/hzalaz))

## [1.0.0](https://github.com/auth0/Lock.iOS-OSX/tree/1.0.0) (2014-10-06)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.12...1.0.0)

## [0.0.12](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.12) (2014-10-03)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.0.0-rc.4...0.0.12)

## [1.0.0-rc.4](https://github.com/auth0/Lock.iOS-OSX/tree/1.0.0-rc.4) (2014-10-03)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.0.0-rc3...1.0.0-rc.4)

**Merged pull requests:**

- Basic Objc Example [\#30](https://github.com/auth0/Lock.iOS-OSX/pull/30) ([hzalaz](https://github.com/hzalaz))

## [1.0.0-rc3](https://github.com/auth0/Lock.iOS-OSX/tree/1.0.0-rc3) (2014-10-02)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.0.0-rc2...1.0.0-rc3)

## [1.0.0-rc2](https://github.com/auth0/Lock.iOS-OSX/tree/1.0.0-rc2) (2014-10-01)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.0.0-rc1...1.0.0-rc2)

**Merged pull requests:**

- Remove refresh token classes. [\#29](https://github.com/auth0/Lock.iOS-OSX/pull/29) ([hzalaz](https://github.com/hzalaz))

## [1.0.0-rc1](https://github.com/auth0/Lock.iOS-OSX/tree/1.0.0-rc1) (2014-09-30)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/1.0.0-beta...1.0.0-rc1)

**Closed issues:**

- Supply optional authentication parameters [\#22](https://github.com/auth0/Lock.iOS-OSX/issues/22)

- Show UIWebView for non-native login  [\#21](https://github.com/auth0/Lock.iOS-OSX/issues/21)

- Alignment Issue [\#6](https://github.com/auth0/Lock.iOS-OSX/issues/6)

- Adjust the color and title of the Navigation Bar [\#5](https://github.com/auth0/Lock.iOS-OSX/issues/5)

- Webkit Error [\#4](https://github.com/auth0/Lock.iOS-OSX/issues/4)

- iOS 5S / 64 bits "file was built for archive which is not the arch being linked" [\#3](https://github.com/auth0/Lock.iOS-OSX/issues/3)

**Merged pull requests:**

- Add umbrella header for SDK [\#26](https://github.com/auth0/Lock.iOS-OSX/pull/26) ([hzalaz](https://github.com/hzalaz))

- Feature authentication params [\#25](https://github.com/auth0/Lock.iOS-OSX/pull/25) ([hzalaz](https://github.com/hzalaz))

- WebView Authentication [\#24](https://github.com/auth0/Lock.iOS-OSX/pull/24) ([hzalaz](https://github.com/hzalaz))

- Feature safari authentication [\#23](https://github.com/auth0/Lock.iOS-OSX/pull/23) ([hzalaz](https://github.com/hzalaz))

- Added getTokenInfo method [\#16](https://github.com/auth0/Lock.iOS-OSX/pull/16) ([martinrybak](https://github.com/martinrybak))

- Added Link Accounts Method [\#15](https://github.com/auth0/Lock.iOS-OSX/pull/15) ([reallyseth](https://github.com/reallyseth))

## [1.0.0-beta](https://github.com/auth0/Lock.iOS-OSX/tree/1.0.0-beta) (2014-09-15)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.11...1.0.0-beta)

**Merged pull requests:**

- Minor edits [\#19](https://github.com/auth0/Lock.iOS-OSX/pull/19) ([dschenkelman](https://github.com/dschenkelman))

## [0.0.11](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.11) (2014-08-25)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.10...0.0.11)

**Merged pull requests:**

- Refresh Token + Keychain Sharing sample [\#18](https://github.com/auth0/Lock.iOS-OSX/pull/18) ([mgonto](https://github.com/mgonto))

- Added note explaining that token and client\_id parameters must not be options for delegation [\#17](https://github.com/auth0/Lock.iOS-OSX/pull/17) ([dschenkelman](https://github.com/dschenkelman))

- CocoaPods support [\#14](https://github.com/auth0/Lock.iOS-OSX/pull/14) ([hzalaz](https://github.com/hzalaz))

## [0.0.10](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.10) (2014-05-14)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.9...0.0.10)

## [0.0.9](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.9) (2014-03-31)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.8...0.0.9)

**Merged pull requests:**

- Improved error handling in loginAsync [\#13](https://github.com/auth0/Lock.iOS-OSX/pull/13) ([martinrybak](https://github.com/martinrybak))

## [0.0.8](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.8) (2014-03-31)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.7...0.0.8)

## [0.0.7](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.7) (2014-03-29)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.6...0.0.7)

**Merged pull requests:**

- Fixed 3 issues with login widget [\#12](https://github.com/auth0/Lock.iOS-OSX/pull/12) ([martinrybak](https://github.com/martinrybak))

## [0.0.6](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.6) (2014-03-26)

[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/0.0.5...0.0.6)

**Closed issues:**

- Tag version number so a podspec can be published [\#11](https://github.com/auth0/Lock.iOS-OSX/issues/11)

- Functions should return a block \(even if there is an error\) [\#10](https://github.com/auth0/Lock.iOS-OSX/issues/10)

- Improve error handling [\#9](https://github.com/auth0/Lock.iOS-OSX/issues/9)

## [0.0.5](https://github.com/auth0/Lock.iOS-OSX/tree/0.0.5) (2014-02-28)

**Implemented enhancements:**

- Prepare library for iOS 7 [\#1](https://github.com/auth0/Lock.iOS-OSX/issues/1)

**Fixed bugs:**

- keyboard covers email and password fields [\#8](https://github.com/auth0/Lock.iOS-OSX/issues/8)

**Closed issues:**

- Getting an error when trying to connect via Facebook [\#7](https://github.com/auth0/Lock.iOS-OSX/issues/7)

- Add logout [\#2](https://github.com/auth0/Lock.iOS-OSX/issues/2)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*