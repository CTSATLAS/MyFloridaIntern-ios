//
//  AppointmentSessionViewController.m
//  MyFloridaIntern
//
//  Created by Brandon Cordell on 1/16/17.
//  Copyright © 2017 Complete Technology Solutions. All rights reserved.
//

#import "AppointmentSessionViewController.h"

@interface AppointmentSessionViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@end

@implementation AppointmentSessionViewController {
    OTPublisher* _publisher;
    OTSession *_session;
    OTSubscriber* _subscriber;
    NSString *token;
    BOOL subscriberCurrentlyConnected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the custom back button
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    subscriberCurrentlyConnected = NO;
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.completetechnologysolutions.myfloridaintern"];
    NSString *apiToken = keychain[@"apiToken"];

    NSString *urlString = [NSString stringWithFormat:@"https://steve.myfloridaintern.com/app/appointments/get_token/%@", _appointmentId];
    NSDictionary *parameters = @{@"api_token": apiToken};

    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];

    [sessionManager GET:urlString
             parameters:parameters
               progress:nil
                success:^(NSURLSessionTask *task, id responseObject){
                    token = [responseObject objectForKey:@"token"];
                    [self connectToSession];

                }
                failure:^(NSURLSessionTask *operation, NSError *error) {
                    NSLog(@"failed");
                }];
}

-(void)back:(UIBarButtonItem *)sender
{
    if (subscriberCurrentlyConnected) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                       message:@"Your interview has not concluded. Are you sure you'd like to back out?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
        
        [alert addAction:yesAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectToSession {
    // Initialize a new instance of OTSession and begin the connection process
    _session = [[OTSession alloc] initWithApiKey:self.apiKey sessionId:self.sessionId delegate:self];
    
    OTError *error;
    [_session connectWithToken:token error:&error];
    
    if (error) {
        NSLog(@"Unable to connect to the session (%@)", error.localizedDescription);
    }
}

- (void)doPublish {
    _publisher = [[OTPublisher alloc] initWithDelegate:self];
    
    OTError *error;
    [_session publish:_publisher error:&error];
    
    if (error) {
        NSLog(@"Unable to publish (%@)", error.localizedDescription);
    }
    
    [_publisher.view setFrame:CGRectMake(0, 0, _publisherView.bounds.size.width, _publisherView.bounds.size.height)];
    [_publisherView addSubview:_publisher.view];
}

- (void)doSubscribe:(OTStream*)stream
{
    _subscriber = [[OTSubscriber alloc] initWithStream:stream
                                              delegate:self];
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        NSLog(@"Unable to publish (%@)",
              error.localizedDescription);
    }
}

- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
}


#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"connected: %d", subscriberCurrentlyConnected);
    
    return YES;
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"Connected to the session.");
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}

- (void)session:(OTSession*)session
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    if (nil == _subscriber)
    {
        [self doSubscribe:stream];
    }
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"session didFailWithError: (%@)", error);
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    subscriberCurrentlyConnected = YES;
    [_subscriber.view setFrame:CGRectMake(0, 0, _subscriberView.bounds.size.width,
                                          _subscriberView.bounds.size.height)];
    [_subscriberView addSubview:_subscriber.view];
}

- (void)cleanupSubscriber {
    subscriberCurrentlyConnected = NO;
    [_subscriber.view removeFromSuperview];
    _subscriber = nil;
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}
@end
