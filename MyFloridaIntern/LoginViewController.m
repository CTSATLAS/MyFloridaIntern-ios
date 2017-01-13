//
//  LoginViewController.m
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/12/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add padding to the login form fields
    UIView *emailPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _emailField.leftView = emailPaddingView;
    _emailField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *passwordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _passwordField.leftView = passwordPaddingView;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    // Apply a gradient background to the login button
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    buttonGradient.frame = _loginButton.bounds;
    buttonGradient.colors = [NSArray arrayWithObjects:
                             (id)[[UIColor colorWithRed:79.0 / 255.0f green:151.0 / 255.0f blue:209.0 / 255.0f alpha:1.0] CGColor],
                             (id)[[UIColor colorWithRed:28.0 / 255.0f green:117.0 / 255.0f blue:188.0 / 255.0f alpha:1.0] CGColor],
                             nil];
    
    [_loginButton.layer insertSublayer:buttonGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [_loginButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:4.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)attemptLogin:(id)sender {
   
    NSString *email = _emailField.text;
    NSString *password = _passwordField.text;
    NSString *urlString = @"https://steve.myfloridaintern.com/api/login";

    NSDictionary *parameters = @{@"email": email, @"password": password};
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    
    [sessionManager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject){
        NSDictionary *responseDict = (NSDictionary *) responseObject;
        
        // Save the api_token for later requests
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.completetechnologysolutions.myfloridaintern"];
        keychain[@"apiToken"] = responseDict[@"api_token"];
        
        // Switch to the logged in view
        [[UIApplication sharedApplication].keyWindow setRootViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController]];
    } failure:^(NSURLSessionTask *operation, NSError *error){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Login Incorrect"
                                                                       message:@"Your email and/or password was incorrect"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (IBAction)loginPressed:(id)sender {
    
}

@end
