## Usage

1. Git clone and reference the library in your project

  ~~~bash
  git clone git@github.com:auth0/Auth0.iPhone.git
  ~~~

  * Go to your project 
  * Right-click in the Frameworks folder and select ___Add Files to "Your Project Name"___
  * Go to the Auth0.iPhone, select the iAuth0Client folder, ensure that your project target is selected and press __Add__

2. Instantiate Auth0Client

~~~objective-c
Auth0Client *client = [Auth0Client auth0Client:@"youraccount.auth0.com" 
								 clientId:@"Your Client ID" 
								 clientSecret:@"Your Client Secret"];
~~~

3. Trigger login (with Widget) 

~~~objective-c
[client loginAsync:self withCompletionHandler:^(BOOL authenticated) {
    if (!authenticated) {
        NSLog(@"Error authenticating");
    }
    else{            
        // * Use client.auth0User to do wonderful things, e.g.:
		// - get user email => [client.auth0User.Profile objectForKey:@"email"]
		// - get facebook/google/twitter/etc access token => [[[client.auth0User.Profile objectForKey:@"identities"] objectAtIndex:0] objectForKey:@"access_token"]
		// - get Windows Azure AD groups => [client.auth0User.Profile objectForKey:@"groups"]
		// - etc.
    }
}];
~~~

![](http://puu.sh/4no9m.png)

Or you can use the connection as a parameter (e.g. here we login with a Windows Azure AD account)

~~~objective-c
[client loginAsync:self connection:@"auth0waadtests.onmicrosoft.com" withCompletionHandler:^(BOOL authenticated) { ... }];
~~~

Or with specific user name and password (only for providers that support this)

~~~objective-c
[client loginAsync:self connection:@"my-db-connection" 
						username:@"username"
						password:@"password"
						withCompletionHandler:^(BOOL authenticated) { ... }];
~~~

---

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter**, or enterprise identity systems like **Windows Azure AD, Google Apps, AD, ADFS or any SAML Identity Provider**. 
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free account in Auth0

1. Go to [Auth0](http://developers.auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.