//
//  SidebarTableViewController.m
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/18/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import "SidebarTableViewController.h"

#import "QRCodeViewController.h"

@interface SidebarTableViewController ()

@end

@implementation SidebarTableViewController {
    NSArray *menuItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUserInformation];
    
    // Style the table
    self.tableView.backgroundColor = [UIColor colorWithRed:32.0f / 255.0f green:32.0f / 255.0f blue:31.0f / 255.0f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithRed:32.0f / 255.0f green:32.0f / 255.0f blue:31.0f / 255.0f alpha:0.0f];
    
    menuItems = @[@"interviewAppointments", @"qrCode"];
}

- (void)loadUserInformation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _userFullName.text = [defaults objectForKey:@"fullName"];
    _userMajor.text = [defaults objectForKey:@"major"];
    
    _userAvatar.layer.cornerRadius = 50.0f;
    _userAvatar.clipsToBounds = YES;
    
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://steve.myfloridaintern.com/img/avatars/m_%@", [defaults objectForKey:@"avatar"]]];
    
    // Create a request to download the image so we can cache it locally
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:avatarURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    // Load the company logo asynchronously
    [_userAvatar setImageWithURLRequest:imageRequest placeholderImage:nil success:nil failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIView *cellBackground = [[UIView alloc] init];
    cellBackground.backgroundColor = [UIColor colorWithRed:79.0 / 255.0f green:151.0 / 255.0f blue:209.0 / 255.0f alpha:1.0];
    [cell setSelectedBackgroundView:cellBackground];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController *)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
}

@end
