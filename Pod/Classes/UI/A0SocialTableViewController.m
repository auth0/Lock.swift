//
//  A0SocialTableViewController.m
//  Pods
//
//  Created by Hernan Zalazar on 8/14/14.
//
//

#import "A0SocialTableViewController.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0SocialAuthenticator.h"
#import "UIButton+A0SolidButton.h"
#import "A0ServiceTableViewCell.h"
#import "A0APIClient.h"
#import "A0Errors.h"
#import "A0ProgressButton.h"

#import <libextobjc/EXTScope.h>

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alphaValue])

#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))

#define kCellIdentifier @"ServiceCell"

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0SocialTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) NSDictionary *services;
@property (strong, nonatomic) NSArray *activeServices;
@property (assign, nonatomic) NSInteger selectedService;

@end

@implementation A0SocialTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Login", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"A0ServiceTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kCellIdentifier];
    self.services = [A0SocialTableViewController servicesDictionary];
    self.activeServices = self.application.availableSocialStrategies;
    self.selectedService = NSNotFound;
}

- (void)triggerAuth:(UIButton *)sender {
    @weakify(self);
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile){
        @strongify(self);
        [self setInProgress:NO];
        if (self.onLoginBlock) {
            self.onLoginBlock(profile);
        }
    };

    self.selectedService = sender.tag;
    [self setInProgress:YES];
    A0Strategy *strategy = self.application.availableSocialStrategies[sender.tag];
    [[A0SocialAuthenticator sharedInstance] authenticateForStrategy:strategy withSuccess:^(A0SocialCredentials *socialCredentials) {
        [[A0APIClient sharedClient] authenticateWithSocialStrategy:strategy
                                                 socialCredentials:socialCredentials
                                                           success:successBlock
                                                           failure:^(NSError *error) {
                                                               @strongify(self);
                                                               [self setInProgress:NO];
                                                               showAlertErrorView(NSLocalizedString(@"There was an error logging in", nil), [A0Errors localizedStringForSocialLoginError:error]);
                                                           }];
    } failure:^(NSError *error) {
        @strongify(self);
        [self setInProgress:NO];
        if (error.code != A0ErrorCodeFacebookCancelled && error.code != A0ErrorCodeTwitterCancelled) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                    showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
                    break;
                default:
                    showAlertErrorView(NSLocalizedString(@"There was an error logging in", nil), [A0Errors localizedStringForSocialLoginError:error]);
                    break;
            }
        }
    }];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return CGRectZero;
}

- (void)hideKeyboard {}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activeServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *serviceName = [self.activeServices[indexPath.row] name];
    NSDictionary *serviceInfo = self.services[serviceName];
    UIColor *background = [A0SocialTableViewController colorFromString:serviceInfo[@"background_color"]];
    UIColor *selectedBackground = [A0SocialTableViewController colorFromString:serviceInfo[@"selected_background_color"]];
    A0ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configureWithBackground:background highlighted:selectedBackground symbol:serviceInfo[@"icon_character"] name:serviceName];
    [cell.button addTarget:self action:@selector(triggerAuth:) forControlEvents:UIControlEventTouchUpInside];
    cell.button.tag = indexPath.row;
    [cell.button setInProgress:self.selectedService == indexPath.row];
    return cell;
}

#pragma mark - Utility methods

- (void)setInProgress:(BOOL)inProgress {
    self.view.userInteractionEnabled = !inProgress;
    [self.tableView reloadData];
    if (!inProgress) {
        self.selectedService = NSNotFound;
    }
}

+ (UIColor *)colorFromString:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];

    if (!success) return nil;
    if ([hexString length] <= 6) {
        return UIColorFromRGB(hex);
    } else {
        unsigned color = (hex & 0xFFFFFF00) >> 8;
        CGFloat alpha = 1.0 * (hex & 0xFF) / 255.0;
        return UIColorFromRGBA(color, alpha);
    }
}

+ (NSDictionary *)servicesDictionary {
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"Auth0" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *plistPath = [resourceBundle pathForResource:@"Services" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dictionary;
}

@end
