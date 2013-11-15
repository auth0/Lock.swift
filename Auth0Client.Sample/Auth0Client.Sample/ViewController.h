//
//  ViewController.h
//  Auth0Client.Sample
//
//  Created by Sebastian Iacomuzzi on 11/15/13.
//  Copyright (c) 2013 Sebastian Iacomuzzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)loginWithConnection:(id)sender;
- (IBAction)loginWithWidget:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *loginResult;

@end
