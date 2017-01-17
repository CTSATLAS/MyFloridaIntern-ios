//
//  AppointmentsTableViewCell.h
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/16/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppointmentsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *companyName;
@property (nonatomic, weak) IBOutlet UILabel *appointmentTime;
@property (nonatomic, weak) IBOutlet UIImageView *companyLogo;
@property (nonatomic, weak) IBOutlet UIButton *joinSessionButton;

- (IBAction)joinSession:(id)sender;

@end
