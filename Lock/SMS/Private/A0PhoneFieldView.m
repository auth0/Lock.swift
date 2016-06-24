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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _defaultCountryCode = kDefaultUSCode;
        [self setupLayout];
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _defaultCountryCode = kDefaultUSCode;
        [self setupLayout];
        [self setupViews];
    }
    return self;
}

- (void)setupLayout {
    UITextField *textField = self.textField;
    UIImageView *iconView = self.iconImageView;
    UIButton *codeButton = [UIButton buttonWithType:UIButtonTypeSystem];

    [self removeConstraints:self.constraints];
    codeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:codeButton];

    NSDictionary<NSString *, id> *views = NSDictionaryOfVariableBindings(iconView, textField, codeButton);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(18)-[iconView]-(5)-[codeButton(50)]-(5)-[textField]-(7)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[textField]-(10)-|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:codeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    [iconView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [iconView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self needsUpdateConstraints];

    self.countryCodeButton = codeButton;
}

- (void)setupViews {
    self.type = A0CredentialFieldViewPhoneNumber;
    self.returnKeyType = UIReturnKeyNext;
    A0Theme *theme = [A0Theme sharedInstance];
    self.iconImageView.tintColor = [theme colorForKey:A0ThemeTextFieldIconColor];
    self.textField.tintColor = [theme colorForKey:A0ThemeTextFieldTextColor];
    self.textField.returnKeyType = self.returnKeyType;
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.countryCodeButton.titleLabel.font = [theme fontForKey:A0ThemeTextFieldFont];
    self.countryCodeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.countryCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.countryCodeButton setTitleColor:[theme colorForKey:A0ThemeTextFieldTextColor] forState:UIControlStateNormal];
    [self.countryCodeButton setTitle:self.defaultCountryCode forState:UIControlStateNormal];
    [self.countryCodeButton addTarget:self action:@selector(countryCodeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [theme configureTextField:self.textField];
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
