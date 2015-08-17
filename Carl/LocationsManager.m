//
//  LocationsManager.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "LocationsManager.h"
#import "LocationHelper.h"
#import "Carl.h"
#import "User.h"
#import <Firebase/Firebase.h>

#define CARL_METERS_PER_SECOND 1.0 // human walking is 1.3
#define UPDATE_USER_STATUS_INTERVAL_SECONDS 1.0

@interface LocationsManager () <CLLocationManagerDelegate>

@property (nonatomic, retain) Carl *carl;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation LocationsManager

@synthesize updateMode = _updateMode;
@synthesize userStatus = _userStatus;
@synthesize metersBetweenUserAndCarl = _metersBetweenUserAndCarl;
@synthesize metersCarlIsNorthOfUser = _metersCarlIsNorthOfUser;
@synthesize metersCarlIsEastOfUser = _metersCarlIsEastOfUser;
@synthesize userHeading = _userHeading;
@synthesize metersFromRunningStartLocation = _metersFromRunningStartLocation;
@synthesize carl = _carl;
@synthesize user = _user;
@synthesize locationManager = _locationManager;
@synthesize timer = _timer;

- (void)startUpdatingUserStatusForeground
{
    if (self.updateMode != UpdateForeground) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            
            self.updateMode = UpdateForeground;

            [self.locationManager stopMonitoringSignificantLocationChanges];
            [self.locationManager startUpdatingLocation];
            [self.locationManager startUpdatingHeading];
        }
        
        [self updateUserStatus];
        
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_USER_STATUS_INTERVAL_SECONDS target:(self) selector:@selector(updateUserStatus) userInfo:nil repeats:YES];
    }
}

- (void)startUpdatingUserStatusBackground
{
    if (self.updateMode != UpdateBackground) {

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            
            self.updateMode = UpdateBackground;

            [self.locationManager stopUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
        
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateUserStatus
{    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loginCompleted"] == YES) {
        
        [self updateUsersLocation];
        [self updateCarlsLocation];
        
        BOOL foundUserStatus = NO;
        
        if (self.userStatus == Running) {
            
            foundUserStatus = YES;
            
            NSDictionary *locationDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"runningFromLocation"];
            if (locationDict) {
                
                CLLocation *location = [[CLLocation alloc] initWithLatitude:[[locationDict valueForKey:@"latitude"] floatValue] longitude:[[locationDict valueForKey:@"longitude"] floatValue]];
                
                CLLocationDistance metersApart = [self.user.location distanceFromLocation:location];
                
                self.metersFromRunningStartLocation = [NSNumber numberWithInt:metersApart];

                if (metersApart > 100) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"runningFromLocation"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self relocateCarl];
                }
            }
        }
        
        if ([self.carl location] && [self.user location]) {
            NSDate *eatenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"eatenDate"];
            if (eatenDate) {
                int secondsUntilEaten = [eatenDate timeIntervalSinceDate:[NSDate date]];
                if (secondsUntilEaten <= 1) { // 1 for the issues in complete accuracy
                    self.userStatus = Eaten;
                    foundUserStatus = YES;
                }
            }
            if (!foundUserStatus) {
                NSDate *attackedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"attackedDate"];
                if (attackedDate) {
                    int secondsUntilAttacked = [attackedDate timeIntervalSinceDate:[NSDate date]];
                    if (secondsUntilAttacked <= 1) { // 1 for the issues in complete accuracy
                        if (self.userStatus != Running) {
                            self.userStatus = UnderAttack;
                            foundUserStatus = YES;
                        }
                    }
                    else {
                        self.userStatus = Safe;
                        foundUserStatus = YES;
                    }
                }
                else {
                    self.userStatus = Safe;
                    foundUserStatus = YES;
                }
            }
        }

        [self updateSignificantTimes];
        
        if (!foundUserStatus) {
            self.userStatus = Unknown;
        }
        
        [self updateNotifications];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserStatusUpdated" object:nil];
    }
}

- (void)updateUsersLocation
{
    [self.user setLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
}

- (void)updateCarlsLocation
{
    CLLocation *usersLocation = [self.user location];

    if ([self.carl location] == nil) {
        
        if (usersLocation != nil) {
            
            float additionalLatitude = [LocationHelper latitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:9656 maxMeters:16093]];
            float additionalLongitude = [LocationHelper longitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:9656 maxMeters:16093]];

            [self.carl setLatitude:usersLocation.coordinate.latitude + additionalLatitude longitude:usersLocation.coordinate.longitude + additionalLongitude];
        }
    }
    
    if ([self.carl location] != nil) {
        
        float metersMoved = CARL_METERS_PER_SECOND * [[NSDate date] timeIntervalSinceDate:[self.carl lastMoved]];
        
        CLLocation *carlsNewLocation = [LocationHelper moveLocation:[self.carl location] towardsLocation:self.locationManager.location meters:metersMoved];
        [self.carl setLatitude:carlsNewLocation.coordinate.latitude longitude:carlsNewLocation.coordinate.longitude];
        
        CLLocationDistance metersApart = [[self.carl location] distanceFromLocation:usersLocation];
        CLLocationDistance metersApartNorth = [LocationHelper latitudeDifferenceNorthInMetersBetweenLocation1:[self.carl location] location2:usersLocation];
        CLLocationDistance metersApartEast = [LocationHelper longitudeDifferenceEastInMetersBetweenLocation1:[self.carl location] location2:usersLocation];
        
        self.metersBetweenUserAndCarl = [NSNumber numberWithFloat:metersApart];
        self.metersCarlIsNorthOfUser = [NSNumber numberWithFloat:metersApartNorth];
        self.metersCarlIsEastOfUser = [NSNumber numberWithFloat:metersApartEast];
    }
}

- (void)updateSignificantTimes
{
    if ([self.carl location] && [self.user location] && [[NSUserDefaults standardUserDefaults] boolForKey:@"loginCompleted"] == YES) {

        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"] == nil) {
            NSDate *startDate = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:startDate forKey:@"startDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (self.userStatus == Safe) {
            CLLocationDistance metersApart = [[self.carl location] distanceFromLocation:[self.user location]];
            
            float secondsTillAttacked = metersApart / CARL_METERS_PER_SECOND;
            
            NSDate *attackedDate = [NSDate dateWithTimeIntervalSinceNow:secondsTillAttacked];
            
            [[NSUserDefaults standardUserDefaults] setObject:attackedDate forKey:@"attackedDate"];
            
            // Only reset the eaten date if we arent past the attacked date.
            
            int secondsUntilAttacked = [attackedDate timeIntervalSinceDate:[NSDate date]];
            if (secondsUntilAttacked <= 0) {

            }
            else {
                NSDate *eatenDate = [attackedDate dateByAddingTimeInterval:60 * 5]; //60 * 5
                [[NSUserDefaults standardUserDefaults] setObject:eatenDate forKey:@"eatenDate"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com"];
        if (ref.authData) {
            
            int seconds = [[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"]];
            ref = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://carlishungry.firebaseio.com/users/%@", [ref.authData uid]]];
            
            NSDate *startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"];

            if (self.userStatus != Eaten) {
                
                [ref updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:seconds], @"confirmedSecondsAlive", nil]];
            }
            else {
                
                NSDate *eatenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"eatenDate"];
                
                int secondsLived = [eatenDate timeIntervalSinceDate:startDate];

                [ref updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:secondsLived], @"confirmedSecondsAlive", [NSNumber numberWithInt:[eatenDate timeIntervalSince1970]], @"eatenDate", [NSNumber numberWithInt:[startDate timeIntervalSince1970]], @"startDate", nil]];
            }
        }
    }
}

- (void)restart
{
    [self.timer invalidate];
    
    self.userStatus = Safe;
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"carlLastMoved"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"carlsLocation"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"runningFromLocation"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"eatenDate"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"attackedDate"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usersLocation"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"startDate"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"carlLastMovedFromSleep"];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_USER_STATUS_INTERVAL_SECONDS target:(self) selector:@selector(updateUserStatus) userInfo:nil repeats:YES];
}

- (void)updateNotifications
{
    NSArray *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduledLocalNotifications) {
        int secondsSinceOldNotification = [notification.fireDate timeIntervalSinceDate:[NSDate date]];
        if (secondsSinceOldNotification <= 0) {
            // Its already fired... leave it be, dont cancel it.
        }
        else {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    if (self.userStatus == Safe) {
        NSDate *attackedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"attackedDate"];
        if (attackedDate) {
            
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = attackedDate;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is attacking you!!! Open the app to run/distract Carl!";
                [self scheduleNotificationIfInFuture:notification];
            }
            
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 1];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is soooo close...";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 2];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is closing in...";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 5];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is close enough to see you!";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 15];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl can smell you he's sooo close...";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 30];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is on your trail. Closing in.";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 60 * 4];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is far away. Breathe easy.";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [attackedDate dateByAddingTimeInterval:-60 * 60 * 6];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl is really far away. Rest easy.";
                [self scheduleNotificationIfInFuture:notification];
            }
        }
    }

    if (self.userStatus == Safe || self.userStatus == UnderAttack || self.userStatus == Running) {

        NSDate *eatenDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"eatenDate"];
        if (eatenDate) {
            
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = eatenDate;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl ate you. You are dead. :(";
                [self scheduleNotificationIfInFuture:notification];
            }
            
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [eatenDate dateByAddingTimeInterval:-60 * 1];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl's about to eat you!!!!";
                [self scheduleNotificationIfInFuture:notification];
            }
            
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [eatenDate dateByAddingTimeInterval:-60 * 2];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Carl's about to eat you! Open the app to get away!!!";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [eatenDate dateByAddingTimeInterval:-60 * 3];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Open the app!!! Carl is about to eat you! You will die! Ah!";
                [self scheduleNotificationIfInFuture:notification];
            }

            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [eatenDate dateByAddingTimeInterval:-60 * 4];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = @"Open the app to run away or distract Carl!";
                [self scheduleNotificationIfInFuture:notification];
            }
        }
    }
}

- (void)scheduleNotificationIfInFuture:(UILocalNotification *)notification
{
    if ([[NSDate date] compare:notification.fireDate] == NSOrderedAscending) {
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)relocateCarl
{
    float additionalLatitude = [LocationHelper latitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:9656 maxMeters:16093]];
    float additionalLongitude = [LocationHelper longitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:9656 maxMeters:16093]];
    
    [self.carl setLatitude:[self.user location].coordinate.latitude + additionalLatitude longitude:[self.user location].coordinate.longitude + additionalLongitude];
    
    self.userStatus = Safe;
    
    [self updateSignificantTimes];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserStatusUpdated" object:nil];
}

- (void)relocateCarlCloseForTesting
{
    float additionalLatitude = [LocationHelper latitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:4 maxMeters:5]];
    float additionalLongitude = [LocationHelper longitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:4 maxMeters:5]];
    
    [self.carl setLatitude:[self.user location].coordinate.latitude + additionalLatitude longitude:[self.user location].coordinate.longitude + additionalLongitude];
    
    self.userStatus = Safe;
    
    [self updateSignificantTimes];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserStatusUpdated" object:nil];
}

- (void)relocateCarlFromSleep
{
    if ([self canSleep]) {

        float additionalLatitude = [LocationHelper latitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:26000 maxMeters:26001]];
        float additionalLongitude = [LocationHelper longitudeFromMeters:[LocationHelper randomMetersCountBetweenWithMinMeters:26000 maxMeters:26001]];
        
        [self.carl setLatitude:[self.user location].coordinate.latitude + additionalLatitude longitude:[self.user location].coordinate.longitude + additionalLongitude];
        
        self.userStatus = Safe;
        
        [self updateSignificantTimes];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserStatusUpdated" object:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"carlLastMovedFromSleep"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)canSleep
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"carlLastMovedFromSleep"] == nil) {
        return YES;
    }
    
    int secondsSinceOldNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"carlLastMovedFromSleep"] timeIntervalSinceDate:[NSDate date]];
    if (secondsSinceOldNotification <= 60 * 60 * 24 * -1.0) {
        return YES;
    }

    return NO;
}

- (void)startRunning
{
    self.userStatus = Running;
    
    NSDictionary *locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[self.user location].coordinate.latitude], @"latitude", [NSNumber numberWithFloat:[self.user location].coordinate.longitude], @"longitude", nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:locationDict forKey:@"runningFromLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Singleton Methods

+ (id)sharedLocationsManager
{
    static LocationsManager *sharedLocationsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationsManager = [[self alloc] init];
    });
    return sharedLocationsManager;
}

- (id)init
{
    if (self = [super init]) {
        self.updateMode = UpdateNone;
        self.userStatus = Unknown;

        self.carl = [[Carl alloc] init];
        self.user = [[User alloc] init];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

#pragma mark CLLocationManager Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                [self startUpdatingUserStatusForeground];
            }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {

        UIApplication *app = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier locationUpdateTaskID = [app beginBackgroundTaskWithExpirationHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                    [app endBackgroundTask:locationUpdateTaskID];
                    locationUpdateTaskID = UIBackgroundTaskInvalid;
                }
            });
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self updateUserStatus];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (locationUpdateTaskID != UIBackgroundTaskInvalid) {
                    [app endBackgroundTask:locationUpdateTaskID];
                    locationUpdateTaskID = UIBackgroundTaskInvalid;
                }
            });
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.userHeading = [NSNumber numberWithDouble:newHeading.magneticHeading];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserUpdatedHeading" object:nil];
}

@end
