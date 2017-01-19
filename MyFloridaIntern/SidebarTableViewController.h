//
//  SidebarTableViewController.h
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/18/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <UIKit/UIKit.h>

@interface SidebarTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *userFullName;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userMajor;

@end
