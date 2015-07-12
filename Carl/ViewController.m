//
//  ViewController.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "ViewController.h"
#import "LocationsManager.h"
#import <Firebase/Firebase.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AudioToolbox/AudioToolbox.h>

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
#define METERS_TO_RIGHT_EDGE_OF_DEVICE 22758

@interface ViewController () <FBSDKAppInviteDialogDelegate>

@property (nonatomic, retain) LocationsManager *locationsManager;
@property (weak, nonatomic) IBOutlet UILabel *carlLabel;
@property (nonatomic, retain) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *runButton;
@property (weak, nonatomic) IBOutlet UIButton *distractButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *sleepButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *testButton;

@end

@implementation ViewController

@synthesize locationsManager = _locationsManager;
@synthesize timer = _timer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationsManager = [LocationsManager sharedLocationsManager];

    self.textView.hidden = YES;
    self.runButton.hidden = YES;
    self.distractButton.hidden = YES;
    self.sleepButton.hidden = YES;
    self.leaderboardButton.hidden = YES;
    self.shareButton.hidden = YES;
    self.testButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userStatusUpdated:) name:@"UserStatusUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdatedHeading:) name:@"UserUpdatedHeading" object:nil];
    
    self.carlLabel.hidden = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:(self) selector:@selector(update) userInfo:nil repeats:YES];
    
    self.textView.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    self.textView.textColor = [UIColor greenColor];
    self.textView.userInteractionEnabled = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    
    self.sleepButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.sleepButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.leaderboardButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.leaderboardButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.runButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.runButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.distractButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.distractButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.shareButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.testButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.testButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];

    self.textView.hidden = YES;

    if (grantedSettings.types == UIUserNotificationTypeNone) {
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
    else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
    else {
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
        if (ref.authData) {
            self.textView.hidden = NO;
            [self.locationsManager startUpdatingUserStatusForeground];

        } else {
            [self performSegueWithIdentifier:@"Login" sender:self];
        }
    }
}

- (IBAction)runSelected:(id)sender
{
    if (self.locationsManager.userStatus == UnderAttack) {
        [self.locationsManager startRunning];
    }
}

- (IBAction)distractSelected:(id)sender
{
    if (self.locationsManager.userStatus == UnderAttack || self.locationsManager.userStatus == Running) {
        
        FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
        
        content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1620733238174182"];
        [FBSDKAppInviteDialog showWithContent:content delegate:self];
    }
}

- (IBAction)testSelected:(id)sender
{
    if (self.locationsManager.userStatus == Safe) {
        [self.locationsManager relocateCarlCloseForTesting];
    }
}

- (IBAction)shareSelected:(id)sender
{
    NSDate *startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"];
    NSDate *eatenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"eatenDate"];
    int secondsLived = [eatenDate timeIntervalSinceDate:startDate];
    
    NSString *shareText = [NSString stringWithFormat:@"Carl ate me. I survived %.2f mins. #CarlAteMe #Carl👾", secondsLived / 60.0];
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    [sharingItems addObject:shareText];
    [sharingItems addObject:[NSURL URLWithString:@"http://itunes.apple.com/app/1018286619"]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypeMessage,
                                         UIActivityTypeMail,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)sleepSelected:(id)sender
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Need some sleep?"
                                          message:@"Once every 24 hours you can respectfully ask Carl to let you sleep. He will kindly move himself to be about 8 hours away from you. Carl can respect sleep. He likes sleep too. Want to move him now?"
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Not Yet...", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Sleep Time!", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if (self.locationsManager.userStatus == Safe) {
                                       [self.locationsManager relocateCarlFromSleep];
                                   }
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    if ([[results valueForKey:@"completionGesture"] isEqualToString:@"cancel"])
    {
        
    }
    else {
        if (self.locationsManager.userStatus == UnderAttack || self.locationsManager.userStatus == Running) {
            [self.locationsManager relocateCarl];
        }
    }
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    
}

- (void)userStatusUpdated:(NSNotification *)notification
{
    [self updateCarlPositionOnMap];
}

- (void)userUpdatedHeading:(NSNotification *)notification
{
    [self updateCarlPositionOnMap];
}

- (void)update
{
    if (self.locationsManager.userStatus == Safe) {
        self.runButton.hidden = YES;
        self.distractButton.hidden = YES;
        if ([self.locationsManager canSleep]) {
            self.sleepButton.hidden = NO;
        }
        else {
            self.sleepButton.hidden = YES;
        }
        self.leaderboardButton.hidden = NO;
        self.shareButton.hidden = YES;
        self.testButton.hidden = YES;
    }
    else if (self.locationsManager.userStatus == UnderAttack) {
        self.runButton.hidden = NO;
        self.distractButton.hidden = NO;
        self.sleepButton.hidden = YES;
        self.leaderboardButton.hidden = YES;
        self.shareButton.hidden = YES;
        self.testButton.hidden = YES;

        [self transitionToAttackedMode];
    }
    else if (self.locationsManager.userStatus == Running) {
        self.runButton.hidden = YES;
        self.distractButton.hidden = NO;
        self.sleepButton.hidden = YES;
        self.leaderboardButton.hidden = YES;
        self.shareButton.hidden = YES;
        self.testButton.hidden = YES;

        [self transitionToAttackedMode];
    }
    else if (self.locationsManager.userStatus == Eaten) {
        self.runButton.hidden = YES;
        self.distractButton.hidden = YES;
        self.sleepButton.hidden = YES;
        self.leaderboardButton.hidden = NO;
        self.shareButton.hidden = NO;
        self.testButton.hidden = YES;
        [self transitionToEatenMode];
    }
    else if (self.locationsManager.userStatus == Unknown) {
        self.runButton.hidden = YES;
        self.distractButton.hidden = YES;
        self.sleepButton.hidden = YES;
        self.leaderboardButton.hidden = YES;
        self.shareButton.hidden = YES;
        self.testButton.hidden = YES;
    }
    
    NSDate *attackedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"attackedDate"];
    int secondsUntilAttacked = [attackedDate timeIntervalSinceDate:[NSDate date]];
    NSDate *eatenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"eatenDate"];
    int secondsUntilEaten = [eatenDate timeIntervalSinceDate:[NSDate date]];
    
    if (self.locationsManager.userStatus == Safe) {
        
        self.textView.text = [NSString stringWithFormat:@"Carl is:\n%.2f miles away\n%.2f hours until arrival", [self.locationsManager.metersBetweenUserAndCarl floatValue] / 1609.34, secondsUntilAttacked / 60.0 / 60];
    }
    else if (self.locationsManager.userStatus == UnderAttack) {
        
        self.textView.text = [NSString stringWithFormat:@"Under attack:\n%.2f mins til eaten. Quick! Do something!", secondsUntilEaten / 60.0];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    else if (self.locationsManager.userStatus == Running) {
        
        self.textView.text = [NSString stringWithFormat:@"Running away:\n%.2f mins til eaten. Run %i more meters to escape!", secondsUntilEaten / 60.0, 100 - [self.locationsManager.metersFromRunningStartLocation intValue]];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    else if (self.locationsManager.userStatus == Eaten) {
        
        NSDate *startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"];
        NSDate *eatenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"eatenDate"];
        int secondsLived = [eatenDate timeIntervalSinceDate:startDate];
        
        self.textView.text = [NSString stringWithFormat:@"You survived %.2f hours. Now you are eaten.", secondsLived / 60.0 / 60.0];
    }
    else {
        self.textView.text = @"";
    }
}

- (void)transitionToAttackedMode
{
    self.carlLabel.font = [UIFont systemFontOfSize:self.view.frame.size.width];
    self.carlLabel.hidden = NO;
    self.carlLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    self.carlLabel.center = self.view.center;
    self.carlLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    
    [UIView animateWithDuration:1.0f animations:^{
        self.carlLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }];
}

- (void)transitionToEatenMode
{
    self.carlLabel.font = [UIFont systemFontOfSize:self.view.frame.size.width];
    [self.carlLabel setText:@"😲"];
    self.carlLabel.hidden = NO;
    self.carlLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    self.carlLabel.center = self.view.center;
    self.carlLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
    
    [UIView animateWithDuration:1.0f animations:^{
        self.carlLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }];
}

- (void)updateCarlPositionOnMap
{
    if (self.locationsManager.userStatus == Safe) {
        
        if ([self.locationsManager metersBetweenUserAndCarl] && [self.locationsManager metersCarlIsNorthOfUser] && [self.locationsManager metersCarlIsEastOfUser]) {
            
            float middleX = self.view.frame.size.width / 2;
            float middleY = self.view.frame.size.height / 2;
            float metersInPoint = (self.view.frame.size.width / 2) / METERS_TO_RIGHT_EDGE_OF_DEVICE;
            float maxCarlFontSize = self.view.frame.size.width / 5;
            
            float carlFontSize = maxCarlFontSize - (([[self.locationsManager metersBetweenUserAndCarl] floatValue] / METERS_TO_RIGHT_EDGE_OF_DEVICE) * maxCarlFontSize);
            
            if (carlFontSize < 26) {
                carlFontSize = 26;
            }
            
            float carlWidth = carlFontSize * 3.5;
            
            self.carlLabel.font = [UIFont systemFontOfSize:carlFontSize];
            self.carlLabel.textAlignment = NSTextAlignmentCenter;
            self.carlLabel.backgroundColor = [UIColor clearColor];
            
            float y = (metersInPoint * [[self.locationsManager metersCarlIsNorthOfUser] floatValue]);
            
            y = y * -1;
            
            float x = (metersInPoint * [[self.locationsManager metersCarlIsEastOfUser] floatValue]);
            
            float radians = degreesToRadians([[self.locationsManager userHeading] doubleValue] * -1);
            
            float newX = 0 + ((x-0) * cos(radians)) - ((y-0) * sin(radians));
            float newY = 0 + ((x-0) * sin(radians)) + ((y-0) * cos(radians));
            
            self.carlLabel.hidden = NO;
            self.carlLabel.frame = CGRectMake(middleX + newX - (carlWidth / 2), middleY + newY - (carlWidth / 2), carlWidth, carlWidth);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
