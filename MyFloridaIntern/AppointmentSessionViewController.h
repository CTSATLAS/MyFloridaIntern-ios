//
//  AppointmentSessionViewController.h
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/16/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <OpenTok/OpenTok.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <UIKit/UIKit.h>

@interface AppointmentSessionViewController : UIViewController

@property (nonatomic, strong) NSString *appointmentId;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *apiKey;

- (void)connectToSession;

@end
