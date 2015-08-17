//
//  LogInViewController.m
//  Carl
//
//  Created by Zach Whelchel on 7/9/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "LogInViewController.h"
#import <Firebase/Firebase.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TwitterAuthHelper.h"

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) UILabel *carlLabel;
@property (nonatomic, retain) NSTimer *timer;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *titles;
@property (nonatomic) int currentPage;

@end

@implementation LogInViewController

@synthesize carlLabel = _carlLabel;
@synthesize timer = _timer;
@synthesize locationManager = _locationManager;
@synthesize titles = _titles;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nextButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.nextButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.notificationsButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.notificationsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.locationButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.facebookButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.facebookButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
    
    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
            [self.facebookButton setBackgroundColor:[UIColor greenColor]];
        } else {
            [self.facebookButton setBackgroundColor:[UIColor redColor]];
        }
    }];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:(self) selector:@selector(updatePermissions) userInfo:nil repeats:YES];
    
    self.notificationsButton.hidden = YES;
    self.locationButton.hidden = YES;
    self.facebookButton.hidden = YES;
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = NO;
    
    float maxCarlFontSize = self.view.frame.size.width / 5;
    
    self.carlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxCarlFontSize, maxCarlFontSize)];
    self.carlLabel.numberOfLines = 0;
    [self.carlLabel setFont:[UIFont systemFontOfSize:maxCarlFontSize]];
    [self.carlLabel setText:@"👾"];
    [self.carlLabel setTextColor:[UIColor blackColor]];
    
    self.carlLabel.textAlignment = NSTextAlignmentCenter;
    
    self.carlLabel.center = CGPointMake(self.view.center.x, self.view.center.y) ;
    [self.view addSubview:self.carlLabel];
    
    self.titles = [NSArray arrayWithObjects:[NSString stringWithFormat:@"This is Carl."], [NSString stringWithFormat:@"Carl is hungry."], [NSString stringWithFormat:@"Carl eats people."], [NSString stringWithFormat:@"Carl would like to eat you."], [NSString stringWithFormat:@"Carl will chase you, wherever you go."], [NSString stringWithFormat:@"Carl is slow, but he never rests. He only creeps closer."], [NSString stringWithFormat:@"If Carl gets too close, you have 2 options..."], [NSString stringWithFormat:@"1) Open the app to run away quickly."], [NSString stringWithFormat:@"2) Invite a friend to distract Carl."], [NSString stringWithFormat:@"If you do not escape in time, Carl eats you."], [NSString stringWithFormat:@"Ready?"], [NSString stringWithFormat:@"First we need to enable a few things…"], nil];
    
    for (int i = 0; i < self.titles.count; i++) {
        
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 140)];
        [textView setText:[self.titles objectAtIndex:i]];
        
        [subview addSubview:textView];
        
        
        textView.font = [UIFont fontWithName:@"Coder's Crux" size:40];
        textView.textColor = [UIColor greenColor];

        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = NO;
        
        [self.scrollView addSubview:subview];
    }
    
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * (self.titles.count), self.scrollView.frame.size.height);
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updatePermissions
{
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        [self.notificationsButton setBackgroundColor:[UIColor redColor]];
    }
    else {
        [self.notificationsButton setBackgroundColor:[UIColor greenColor]];
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationButton setBackgroundColor:[UIColor redColor]];
    }
    else {
        [self.locationButton setBackgroundColor:[UIColor greenColor]];
    }
}

- (IBAction)nextSelected:(id)sender
{
    if (self.currentPage < self.titles.count) {
        self.currentPage++;
    }

    if (self.currentPage < self.titles.count) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.frame.size.width, 0) animated:NO];
    }
    
    if (self.currentPage == self.titles.count - 1) {
        self.carlLabel.hidden = YES;
        self.notificationsButton.hidden = NO;
        self.locationButton.hidden = NO;
        self.facebookButton.hidden = NO;
        [self.nextButton setTitle:@">Start" forState:UIControlStateNormal];
    }

    if (self.currentPage == self.titles.count) {
        
        if (self.notificationsButton.backgroundColor == [UIColor greenColor] && self.locationButton.backgroundColor == [UIColor greenColor] && self.facebookButton.backgroundColor == [UIColor greenColor]) {
            
            Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
            Firebase *ref2 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://carlishungry.firebaseio.com/users/%@", [ref.authData uid]]];
            [ref2 observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                
                if ([snapshot exists] && [snapshot.value valueForKey:@"eatenDate"] != nil && [snapshot.value valueForKey:@"startDate"] != nil) {

                    // Permadeath catcher
                    
//                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[snapshot.value valueForKey:@"startDate"] doubleValue]];
//                    [[NSUserDefaults standardUserDefaults] setObject:startDate forKey:@"startDate"];
//
//                    NSDate *eatenDate = [NSDate dateWithTimeIntervalSince1970:[[snapshot.value valueForKey:@"eatenDate"] doubleValue]];
//                    [[NSUserDefaults standardUserDefaults] setObject:eatenDate forKey:@"eatenDate"];
//
//                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loginCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self dismissViewControllerAnimated:NO completion:^{
                    
                }];

            } withCancelBlock:^(NSError *error) {
                
            }];
        }
        else {
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Please enable"
                                                  message:@"You need to enable all of the above options before we can start!"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"OK!", @"Cancel action")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Cancel action");
                                           }];
            
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (IBAction)notificationsSelected:(id)sender
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }

}

- (IBAction)locationSelected:(id)sender
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
}

- (IBAction)facebookSelected:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Account"
                                          message:@"Choose a sign in method."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *facebookAction = [UIAlertAction
                                   actionWithTitle:@"Facebook"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                       Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
                                       FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
                                       
                                       [facebookLogin logInWithReadPermissions:@[@"public_profile"]
                                                                       handler:^(FBSDKLoginManagerLoginResult *facebookResult, NSError *facebookError) {
                                                                           
                                                                           if (facebookError) {
                                                                               NSLog(@"Facebook login failed. Error: %@", facebookError);
                                                                           } else if (facebookResult.isCancelled) {
                                                                               NSLog(@"Facebook login got cancelled.");
                                                                           } else {
                                                                               NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
                                                                               
                                                                               [ref authWithOAuthProvider:@"facebook" token:accessToken
                                                                                      withCompletionBlock:^(NSError *error, FAuthData *authData) {
                                                                                          
                                                                                          if (error) {
                                                                                              NSLog(@"Login failed. %@", error);
                                                                                          } else {
                                                                                              NSLog(@"Logged in! %@", authData);
                                                                                              
                                                                                              
                                                                                              [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                                                                                               startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                                                                   
                                                                                                   if (!error) {
                                                                                                       
                                                                                                       Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
                                                                                                       if (ref.authData) {
                                                                                                           
                                                                                                           ref = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://carlishungry.firebaseio.com/users/%@", [ref.authData uid]]];
                                                                                                           [ref updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:result[@"name"], @"name", nil]];
                                                                                                       }
                                                                                                   }
                                                                                               }];
                                                                                          }
                                                                                      }];
                                                                           }
                                                                       }];

                                       
                                       
                                   }];
    
    [alertController addAction:facebookAction];

    UIAlertAction *twitterAction = [UIAlertAction
                                     actionWithTitle:@"Username"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         
                                         
                                         UIAlertController *alertController2 = [UIAlertController
                                                                               alertControllerWithTitle:@"Username" message:@"Enter a username:" preferredStyle:UIAlertControllerStyleAlert];

                                         
                                         
                                         
                                         [alertController2 addTextFieldWithConfigurationHandler:^(UITextField *K2TextField)
                                          {
                                              K2TextField.placeholder = @"Username";
                                          }];
                                         
                                         
                                         UIAlertAction *okAction = [UIAlertAction
                                                                          actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction *action)
                                                                          {
                                                                              
                                                                              if ([[alertController2.textFields firstObject] text].length > 0) {
                                                                                  Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
                                                                                  [ref authAnonymouslyWithCompletionBlock:^(NSError *error, FAuthData *authData) {
                                                                                      if (error) {
                                                                                          // There was an error logging in anonymously
                                                                                      } else {
                                                                                          // We are now logged in
                                                                                          
                                                                                          Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
                                                                                          if (ref.authData) {
                                                                                              ref = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://carlishungry.firebaseio.com/users/%@", [ref.authData uid]]];
                                                                                              [ref updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:[[alertController2.textFields firstObject] text], @"name", nil]];
                                                                                          }
                                                                                          
                                                                                      }
                                                                                  }];
                                                                              }
                                                                              

                                                                          }];
                                         
                                         [alertController2 addAction:okAction];

                                         
                                         
                                         UIAlertAction *cancelAction = [UIAlertAction
                                                                        actionWithTitle:@"Cancel"
                                                                        style:UIAlertActionStyleCancel
                                                                        handler:^(UIAlertAction *action)
                                                                        {
                                                                            
                                                                        }];
                                         
                                         [alertController2 addAction:cancelAction];
                                         

                                         
                                         [self presentViewController:alertController2 animated:YES completion:nil];

                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                     }];
    
    [alertController addAction:twitterAction];

    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    [alertController addAction:cancelAction];

    
    [self presentViewController:alertController animated:YES completion:nil];

    
    
    
    
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
