#import <UIKit/UIKit.h>

@interface Auth0WebViewController : UIViewController <UIWebViewDelegate> {
@private   
    UIWebView *_webView;
    UIActivityIndicatorView * _spinner;
    NSURL * _url;
    NSURL * _authzUrl;
    NSString * _returnUrl;
    void (^ _block)(NSString* token, NSString * jwtToken, NSString *refreshToken, NSString * error);
	BOOL _allowsClose;
}

- (id)initWithAuthorizeUrl:(NSURL *)authzUrl returnUrl:(NSString*)returnUrl allowsClose:(BOOL)allowsClose withCompletionHandler:(void (^)(NSString * token, NSString * jwtToken, NSString *refreshToken, NSString * error))block;

+ (void)clearCookies;

@end
