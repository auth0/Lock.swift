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

@interface A0CredentialFieldView ()
@property (strong, nonatomic) UIColor *validTextColor;
@end

@implementation A0CredentialFieldView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _validTextColor = self.textField.textColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImageView.image = [self.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setInvalid:(BOOL)invalid {
    [self willChangeValueForKey:@"invalid"];
    _invalid = invalid;
    [self didChangeValueForKey:@"invalid"];
    self.iconImageView.tintColor = invalid ? [UIColor redColor] : nil;
    self.textField.tintColor = invalid ? [UIColor redColor] : nil;
    self.textField.textColor = invalid ? [UIColor redColor] : nil;
}

@end
