//  A0EnterpriseLoginViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0Connection.h"

#import "A0EnterpriseLoginViewController.h"
#import "A0AuthParameters.h"
#import "A0CredentialFieldView.h"
#import "A0DatabaseLoginCredentialValidator.h"

@interface A0EnterpriseLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation A0EnterpriseLoginViewController

- (instancetype)init {
    self =  [super init];
    if (self) {
        self.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:NO];
    }
    return self;
}

- (instancetype)initWithEmail:(NSString *)email {
    self = [self init];
    if (self) {
        NSArray *parts = [email componentsSeparatedByString:@"@"];
        NSString *localPart = [parts firstObject];
        self.defaultUsername = [localPart copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *message = A0LocalizedString(@"Please enter your corporate credentials at %@");
    self.messageLabel.text = [NSString stringWithFormat:message, self.connection.values[@"domain"]];
    self.userField.textField.text = self.defaultUsername;
    [self.parameters setValue:self.connection.name forKey:@"connection"];
}

@end
