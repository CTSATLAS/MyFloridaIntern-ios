//
//  AppointmentsTableViewController.m
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/13/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import "AppointmentsTableViewController.h"

@interface AppointmentsTableViewController ()

@property (nonatomic, retain) NSString *apiToken;

@end

@implementation AppointmentsTableViewController
{
    NSMutableArray  *appointments;
}

@synthesize apiToken;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:244.0f / 255.0f green:247.0f / 255.0f blue:249.0f / 255.0f alpha:1.0f];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    
    // Pull the initial data
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Retrieve data from server

- (void)refreshData
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.completetechnologysolutions.myfloridaintern"];
    apiToken = keychain[@"apiToken"];
    
    NSString *urlString = @"https://steve.myfloridaintern.com/app/appointments/132";
    NSDictionary *parameters = @{@"api_token": apiToken};
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    
    [sessionManager GET:urlString
             parameters:parameters
               progress:nil
                success:^(NSURLSessionTask *task, id responseObject){
                    appointments = responseObject;
                    [self.tableView reloadData];
                    
                    if (self.refreshControl) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"MMM d, h:mm a"];
                        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:32.0f / 255.0f green:32.0f / 255.0f blue:31.0f / 255.0f alpha:1.0f]
                                                                                    forKey:NSForegroundColorAttributeName];
                        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                        self.refreshControl.attributedTitle = attributedTitle;
                        
                        [self.refreshControl endRefreshing];
                    }
                }
                failure:^(NSURLSessionTask *operation, NSError *error) {
                    if (self.refreshControl) {
                        [self.refreshControl endRefreshing];
                    }
                }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [appointments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    NSDictionary *appointment = [appointments objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [appointment objectForKey:@"company_name"];
    cell.detailTextLabel.text = [appointment objectForKey:@"appointment"];
    return cell;
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
