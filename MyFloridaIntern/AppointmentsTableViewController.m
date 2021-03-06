//
//  AppointmentsTableViewController.m
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/13/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>

#import "AppointmentsTableViewController.h"
#import "AppointmentSessionViewController.h"

@interface AppointmentsTableViewController ()

@property (nonatomic, retain) NSString *apiToken;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation AppointmentsTableViewController
{
    NSMutableDictionary *appointments;
}

@synthesize apiToken;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    appointments = [[NSMutableDictionary alloc] init];
    
    // Change color of the back button
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:244.0f / 255.0f green:247.0f / 255.0f blue:249.0f / 255.0f alpha:1.0f];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    
    // Pull the initial data
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Retrieve data from server

- (void)loadData
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.completetechnologysolutions.myfloridaintern"];
    apiToken = keychain[@"apiToken"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"https://steve.myfloridaintern.com/app/appointments/%@", [defaults objectForKey:@"id"]];
    NSDictionary *parameters = @{@"api_token": apiToken};
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    
    [sessionManager GET:urlString
             parameters:parameters
               progress:nil
                success:^(NSURLSessionTask *task, id responseObject){
                    NSLog(@"%@", responseObject);
                    for (id appointment in responseObject) {
                        NSDate *appointmentDate = [NSDate dateWithString:appointment[@"appointment"] formatString:@"y-L-d H:m:s"];
                        NSString *appointmentSectionHeader = [appointmentDate formattedDateWithFormat:@"EEEE, MMMM d"];

                        if (!appointments[appointmentSectionHeader]) {
                            appointments[appointmentSectionHeader] = [NSMutableArray arrayWithObject:appointment];
                        } else {
                            NSMutableArray *appointmentsForKey = [appointments objectForKey:appointmentSectionHeader];
                            [appointmentsForKey addObject:appointment];
                        }
                    }

                    [self.tableView reloadData];
                    
                    if (self.refreshControl) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"MMM d, h:mm a"];
                        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:32.0f / 255.0f
                                                                                                           green:32.0f / 255.0f
                                                                                                            blue:31.0f / 255.0f
                                                                                                           alpha:1.0f]
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

- (void)refreshData {
    [appointments removeAllObjects];
    [self.tableView reloadData];
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *keys = [appointments allKeys];
    return [keys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *keys = [appointments allKeys];
    return [keys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [appointments allKeys];
    NSString *sectionTitle = [keys objectAtIndex:section];
    NSArray *sectionAppointments = [appointments objectForKey:sectionTitle];
    return [sectionAppointments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppointmentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell" forIndexPath:indexPath];
    NSArray *sectionKeys = [appointments allKeys];
    NSString *sectionTitle = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *sectionAppointments = [appointments objectForKey:sectionTitle];
    NSDictionary *appointment = [sectionAppointments objectAtIndex:indexPath.row];
    NSDate *appointmentDate = [NSDate dateWithString:[appointment objectForKey:@"appointment"] formatString:@"y-L-d H:m:s"];
    
    // Circular logo
    cell.companyLogo.layer.cornerRadius = 24.0f;
    cell.companyLogo.clipsToBounds = YES;
    
    cell.companyName.text = [appointment objectForKey:@"company_name"];
    cell.appointmentTime.text = [appointmentDate formattedDateWithFormat:@"h:mma"];    
    NSURL *companyLogoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://steve.myfloridaintern.com/img/avatars/s_%@", [appointment objectForKey:@"avatar"]]];
    
    // Create a request to download the image so we can cache it locally
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:companyLogoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];

    // Load the company logo asynchronously
    [cell.companyLogo setImageWithURLRequest:imageRequest placeholderImage:nil success:nil failure:nil];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SessionSegue"]) {
        // Grab the point of touch for the button so we know what appointment they're trying to join
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        AppointmentSessionViewController *sessionViewController = segue.destinationViewController;
        NSArray *sectionKeys = [appointments allKeys];
        NSString *sectionTitle = [sectionKeys objectAtIndex:indexPath.section];
        NSArray *sectionAppointments = [appointments objectForKey:sectionTitle];
        NSDictionary *selectedAppointment = [sectionAppointments objectAtIndex:indexPath.row];
        
        // Set properties of AppointmentSessionViewController
        sessionViewController.appointmentId = [selectedAppointment objectForKey:@"id"];
        sessionViewController.apiKey = [selectedAppointment objectForKey:@"api_key"];
        sessionViewController.sessionId = [selectedAppointment objectForKey:@"session_id"];
    }
}

@end
