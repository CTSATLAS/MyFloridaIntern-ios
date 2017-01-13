//
//  LoginViewController.h
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/12/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)attemptLogin:(id)sender;
- (IBAction)loginPressed:(id)sender;

@end
