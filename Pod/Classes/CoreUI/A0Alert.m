// A0Alert.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "A0Alert.h"

@interface A0Alert () <UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableDictionary<NSString *, A0AlertButtonCallback> *callbacks;
@property (strong, nonatomic) NSMutableArray<NSString *> *buttons;
@end

@implementation A0Alert

- (instancetype)init {
    self = [super init];
    if (self) {
        _callbacks = [@{} mutableCopy];
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title callback:(A0AlertButtonCallback)callback {
    self.callbacks[title] = [callback copy];
    [self.buttons addObject:title];
}

- (void)show {
    [self showAlertView];
}

+ (A0Alert *)showAlert:(void(^)(A0Alert *alert))builder {
    A0Alert *alert = [[A0Alert alloc] init];
    if (builder) {
        builder(alert);
    }
    [alert show];
    return alert;
}

- (void)showAlertView {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title
                                                    message:self.message
                                                   delegate:self
                                          cancelButtonTitle:self.cancelTitle
                                          otherButtonTitles:nil];
#pragma clang diagnostic pop
    [self.buttons enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        [alert addButtonWithTitle:title];
    }];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = self.buttons[buttonIndex];
    A0AlertButtonCallback callback = self.callbacks[title];
    if (callback) {
        callback();
    }
}
@end
