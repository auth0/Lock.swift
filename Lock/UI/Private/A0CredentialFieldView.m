//  A0CredentialFieldView.m
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

#import "A0CredentialFieldView.h"
#import "A0Theme.h"
#import "Constants.h"

@interface A0CredentialFieldView ()
@property (copy, nonatomic) NSString *placeholderText;
@end

@implementation A0CredentialFieldView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self layoutViews];
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutViews];
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    A0Theme *theme = [A0Theme sharedInstance];
    self.iconImageView.tintColor = [theme colorForKey:A0ThemeTextFieldIconColor];
    self.textField.tintColor = [theme colorForKey:A0ThemeTextFieldTextColor];
    self.textField.returnKeyType = self.returnKeyType;
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.type = A0CredentialFieldViewEmail;
    self.returnKeyType = UIReturnKeyNext;
    [theme configureTextField:self.textField];
}

- (void)setType:(A0CredentialFieldViewType)type {
    _type = type;
    A0Theme *theme = [A0Theme sharedInstance];
    switch (_type) {
        case A0CredentialFieldViewEmail:
            self.placeholderText = A0LocalizedString(@"Email");
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            self.iconImageView.image = [[theme imageForKey:A0ThemeIconEmail] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        case A0CredentialFieldViewEmailOrUsername:
            self.placeholderText = A0LocalizedString(@"Email/Username");
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            self.iconImageView.image = [[theme imageForKey:A0ThemeIconEmail] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        case A0CredentialFieldViewPassword:
            self.placeholderText = A0LocalizedString(@"Password");
            self.textField.keyboardType = UIKeyboardTypeDefault;
            self.textField.secureTextEntry = YES;
            self.iconImageView.image = [[theme imageForKey:A0ThemeIconLock] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        case A0CredentialFieldViewUsername:
            self.placeholderText = A0LocalizedString(@"Username");
            self.textField.keyboardType = UIKeyboardTypeDefault;
            self.iconImageView.image = [[theme imageForKey:A0ThemeIconUsername] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        case A0CredentialFieldViewPhoneNumber:
            self.placeholderText = A0LocalizedString(@"Phone Number");
            self.textField.keyboardType = UIKeyboardTypePhonePad;
            self.iconImageView.image = [[theme imageForKey:A0ThemeIconPhone] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        case A0CredentialFieldViewOTPCode:
            self.placeholderText = A0LocalizedString(@"Verification Code");
            self.textField.secureTextEntry = YES;
            self.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            self.iconImageView.image = [[theme imageForKey:A0ThemeIconLock] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = nil;
    [self setFieldPlaceholderText:self.placeholderText];
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    _returnKeyType = returnKeyType;
    self.textField.returnKeyType = returnKeyType;
}

- (void)layoutViews {
    UITextField *textField = [[UITextField alloc] init];
    UIImageView *iconView = [[UIImageView alloc] init];

    textField.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:iconView];
    [self addSubview:textField];

    NSDictionary<NSString *, id> *views = NSDictionaryOfVariableBindings(iconView, textField);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(18)-[iconView]-(10)-[textField]-(7)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[textField]-(10)-|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    [iconView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [iconView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self needsUpdateConstraints];
    self.textField = textField;
    self.iconImageView = iconView;
}

- (void)setInvalid:(BOOL)invalid {
    [self willChangeValueForKey:@"invalid"];
    _invalid = invalid;
    [self didChangeValueForKey:@"invalid"];
    A0Theme *theme = [A0Theme sharedInstance];
    self.iconImageView.tintColor = invalid ? [UIColor redColor] : [theme colorForKey:A0ThemeTextFieldIconColor];
    self.textField.tintColor = invalid ? [UIColor redColor] : [theme colorForKey:A0ThemeTextFieldTextColor];
    self.textField.textColor = invalid ? [UIColor redColor] : [theme colorForKey:A0ThemeTextFieldTextColor];
    if (invalid) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholderText
                                                                               attributes:@{
                                                                                            NSForegroundColorAttributeName: [UIColor redColor],
                                                                                            }];
    } else {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholderText
                                                                               attributes:@{
                                                                                            NSForegroundColorAttributeName: [[A0Theme sharedInstance] colorForKey:A0ThemeTextFieldPlaceholderTextColor],
                                                                                            }];
    }
}

- (void)setFieldPlaceholderText:(NSString *)placeholderText {
    self.placeholderText = placeholderText;
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText
                                                                           attributes:@{
                                                                                        NSForegroundColorAttributeName: [[A0Theme sharedInstance] colorForKey:A0ThemeTextFieldPlaceholderTextColor],
                                                                                        }];
}
@end
