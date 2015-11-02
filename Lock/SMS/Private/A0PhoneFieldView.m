// A0PhoneFieldView.m
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

#import "A0PhoneFieldView.h"
#import "A0Theme.h"

#define kDefaultUSCode @"+1"

@interface A0PhoneFieldView ()

@property (weak, nonatomic) IBOutlet UIButton *countryCodeButton;

@end

@implementation A0PhoneFieldView

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaultCountryCode = kDefaultUSCode;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _defaultCountryCode = kDefaultUSCode;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _defaultCountryCode = kDefaultUSCode;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    A0Theme *theme = [A0Theme sharedInstance];
    self.countryCodeButton.titleLabel.font = [theme fontForKey:A0ThemeTextFieldFont];
    [self.countryCodeButton setTitleColor:[theme colorForKey:A0ThemeTextFieldTextColor] forState:UIControlStateNormal];
    [self.countryCodeButton setTitle:self.defaultCountryCode forState:UIControlStateNormal];
    [self.countryCodeButton addTarget:self action:@selector(countryCodeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [self.countryCodeButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

- (NSString *)phoneNumber {
    NSString *phoneNumber = self.textField.text;
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[phoneNumber componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
}

- (NSString *)fullPhoneNumber {
    return [[self.countryCode stringByAppendingString:@" "]stringByAppendingString:self.phoneNumber];
}

- (NSString *)countryCode {
    return [self.countryCodeButton titleForState:UIControlStateNormal];
}

- (void)setCountryCode:(NSString *)countryCode {
    [self.countryCodeButton setTitle:[countryCode copy] forState:UIControlStateNormal];
}

- (void)countryCodeButtonTapped:(id)sender {
    if (self.onCountryCodeTapped) {
        self.onCountryCodeTapped(self.countryCode);
    }
}

- (void)setInvalid:(BOOL)invalid {
    [super setInvalid:invalid];
    A0Theme *theme = [A0Theme sharedInstance];
    UIColor *color = invalid ? [UIColor redColor] : [theme colorForKey:A0ThemeTextFieldTextColor];
    [self.countryCodeButton setTitleColor:color forState:UIControlStateNormal];
}

@end
