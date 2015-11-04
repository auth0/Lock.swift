// A0UserProfileViewController,m
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

#import "A0UserProfileViewController.h"

#import <Lock/Lock.h>

@interface A0UserProfileViewController ()
@property (strong, nonatomic) NSDictionary *basicInfo;
@property (strong, nonatomic) NSArray *basicInfoKeys;
@property (strong, nonatomic) NSArray *extraInfoKeys;
@end

@implementation A0UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.basicInfo = @{
                       @"Username": self.authInfo.name,
                       @"UserId": self.authInfo.userId,
                       @"Nickname": self.authInfo.nickname,
                       @"Email": self.authInfo.email ?: @"",
                       @"CreatedAt": [formatter stringFromDate:self.authInfo.createdAt],
                       @"PictureURL": self.authInfo.picture.absoluteString,
                       };
    self.basicInfoKeys = self.basicInfo.allKeys;
    self.extraInfoKeys = self.authInfo.extraInfo.allKeys;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = self.basicInfoKeys.count;
            break;
        case 1:
            count = self.authInfo.identities.count;
            break;
        case 2:
            count = self.authInfo.extraInfo.count;
            break;
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch (section) {
        case 0:
            title = @"Auth0 Info";
            break;
        case 1:
            title = @"Identities";
            break;
        case 2:
            title = @"Extra Info";
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *PropertyCell = @"PropertyCell";
    static NSString *IdentityCell = @"IdentityCell";
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:PropertyCell forIndexPath:indexPath];
            cell.textLabel.text = self.basicInfoKeys[indexPath.row];
            cell.detailTextLabel.text = self.basicInfo[self.basicInfoKeys[indexPath.row]];
            break;
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:IdentityCell forIndexPath:indexPath];
            A0UserIdentity *identity = self.authInfo.identities[indexPath.row];
            cell.textLabel.text = identity.connection;
            cell.detailTextLabel.text = [self.authInfo.identities[indexPath.row] accessToken];
            break;
        }
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:PropertyCell forIndexPath:indexPath];
            cell.textLabel.text = self.extraInfoKeys[indexPath.row];
            NSObject *extraInfoValue = self.authInfo.extraInfo[self.extraInfoKeys[indexPath.row]];
            if ([extraInfoValue isKindOfClass:NSDictionary.class] || [extraInfoValue isKindOfClass:NSArray.class]) {
                cell.detailTextLabel.text = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:extraInfoValue options:0 error:nil] encoding:NSUTF8StringEncoding];
            } else {
                cell.detailTextLabel.text = [extraInfoValue description];
            }
            break;
        }
    }
    return cell;
}

@end
