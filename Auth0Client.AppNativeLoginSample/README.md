## Authentication with Facebook App Native Login Dialog

### How to run the sample?

1. Download (Facebook SDK for iOS)[https://developers.facebook.com/docs/ios/]
2. Copy `FacebookSDK.framework` folder to root of the sample.
3. Run.

#### Use your own API keys
Sample should work out of the box because it is using DEMO API keys. If you want to use your own api keys, perform the following steps:

* Update `Auth0Client.AppNativeLoginSample-Info.plist` file with your Facebook App settings:
	* `FacebookAppID: '{YOUR_FACEBOOK_CLIENT_ID}'`
	* `FacebookDisplayName: '{Display Name you configured in the Facebook Dashboard}'`
	* `URL types -> Item 0 -> URL Schemes -> Item 0: 'fb{YOUR_FACEBOOK_CLIENT_ID}'`
* Update `LoginViewController.m` file with your Auth0 settings:
	* `auth0_domain = @"{YOUR_AUTH0_DOMAIN}"`
	* `auth0_clientId = @"{YOUR_AUTH0_CLIENT_ID}"`
