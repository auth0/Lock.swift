// A0PKCE.m
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

#import "A0PKCE.h"
#import <CommonCrypto/CommonCrypto.h>

NSString *Base64URLSafe(NSData * data) {
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"="
                                                           withString:@""];

    base64String = [base64String stringByReplacingOccurrencesOfString:@"/"
                                                           withString:@"_"];

    base64String = [base64String stringByReplacingOccurrencesOfString:@"+"
                                                           withString:@"-"];
    return base64String;
}

@interface A0PKCE ()
@property (strong, nonatomic) NSString *verifier;
@end

@implementation A0PKCE

- (instancetype)init {
    NSMutableData *data = [NSMutableData dataWithLength:32];
    int result __attribute__((unused)) = SecRandomCopyBytes(kSecRandomDefault, 32, data.mutableBytes);
    NSString *code = Base64URLSafe(data);
    return [self initWithVerifier:code];
}

- (instancetype)initWithVerifier:(NSString *)verifier {
    self = [super init];
    if (self) {
        _verifier = verifier;
        _method = @"S256";
    }
    return self;
}

- (NSString *)challenge {
    CC_SHA256_CTX ctx;

    uint8_t * hashBytes = malloc(CC_SHA256_DIGEST_LENGTH * sizeof(uint8_t));
    memset(hashBytes, 0x0, CC_SHA256_DIGEST_LENGTH);

    NSData *valueData = [self.verifier dataUsingEncoding:NSUTF8StringEncoding];

    CC_SHA256_Init(&ctx);
    CC_SHA256_Update(&ctx, [valueData bytes], (CC_LONG)[valueData length]);
    CC_SHA256_Final(hashBytes, &ctx);

    NSData *hash = [NSData dataWithBytes:hashBytes length:CC_SHA256_DIGEST_LENGTH];

    if (hashBytes) {
        free(hashBytes);
    }

    return Base64URLSafe(hash);
}

- (NSDictionary<NSString *,NSString *> *)authorizationParameters {
    return @{
             @"code_challenge": self.challenge,
             @"code_challenge_method": self.method,
             };
}

- (NSDictionary<NSString *,NSString *> *)tokenParametersWithAuthorizationCode:(NSString *)authorizationCode {
    return @{
             @"code_verifier": self.verifier,
             @"code": authorizationCode,
             };
}
@end
