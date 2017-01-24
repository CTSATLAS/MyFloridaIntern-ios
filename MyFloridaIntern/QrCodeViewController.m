//
//  QrCodeViewController.m
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/18/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

#import "QrCodeViewController.h"

@interface QrCodeViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIImageView *qrCode;

@end

@implementation QrCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // Change color of the back button
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self retrieveQrCode];
}

- (void)retrieveQrCode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *qrCodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://steve.myfloridaintern.com/img/qrcodes/%@.png", [defaults objectForKey:@"id"]]];
    
    // Create a request to download the image so we can cache it locally
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:qrCodeURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    // Load the QR code asynchronously
    [_qrCode setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"qrPlaceholder"] success:nil failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
