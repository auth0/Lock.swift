# Auth0 + AWS API

This is an example project on how to use [Delegation API](https://docs.auth0.com/auth-api#delegated) with AWS

##Requirements

[CocoaPods](http://cocoapods.org)

## Configuring the example

You must set your Auht0 `ClientId` and `Tenant` in this sample so that it works with your Auth0 app. For that, just open the [Info.plist](AWS/Info.plist) file and replace the `Auth0ClientId` and `Auth0Tenant` fields with your account information.

## Running the example

In order to run the project, you need to have `XCode` 6 installed.
Once you have that, just clone the project and run the following:

1. `pod install`
2. `open AWS.xcworkspace`
3.  press `⌘ + R`

Enjoy your iOS app now :).
