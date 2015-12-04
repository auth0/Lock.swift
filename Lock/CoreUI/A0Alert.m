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
#import "Constants.h"

@interface A0Alert () <UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableDictionary<NSString *, A0AlertButtonCallback> *callbacks;
@property (strong, nonatomic) NSMutableArray<NSString *> *buttons;
@end

@implementation A0Alert

- (instancetype)init {
    self = [super init];
    if (self) {
        _callbacks = [@{} mutableCopy];
        _buttons = [@[] mutableCopy];
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title callback:(A0AlertButtonCallback)callback {
    self.callbacks[title] = [callback copy];
    [self.buttons addObject:title];
}

- (void)showInController:(UIViewController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIAlertController class]) {
            [self showAlerControllerFrom:controller];
        } else {
            [self showAlertView];
        }
    });
}

+ (A0Alert *)showInController:(UIViewController *)controller alert:(void(^)(A0Alert *alert))builder {
    A0Alert *alert = [[A0Alert alloc] init];
    if (builder) {
        builder(alert);
    }
    [alert showInController:controller];
    return alert;
}

+ (A0Alert *)showInController:(UIViewController *)controller errorAlert:(void (^)(A0Alert * _Nonnull))builder {
    A0Alert *alert = [[A0Alert alloc] init];
    alert.cancelTitle = A0LocalizedString(@"OK");
    if (builder) {
        builder(alert);
    }
    [alert showInController:controller];
    return alert;
}

- (void)showAlerControllerFrom:(UIViewController *)controller {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleAlert];
    if (self.cancelTitle) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:self.cancelTitle style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
    }
    [self.buttons enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        A0AlertButtonCallback callback = self.callbacks[title];
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callback) {
                callback();
            }
        }];
        [alert addAction:action];
    }];
    [controller presentViewController:alert animated:YES completion:nil];
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
