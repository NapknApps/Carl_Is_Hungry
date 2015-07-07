//
//  CarlManager.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "CarlManager.h"
#import "Carl.h"
#import "LocationHelper.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define CARL_METERS_PER_SECOND 1.0
#define UPDATE_CARL_INTERVAL_SECONDS 5.0

@interface CarlManager () <CLLocationManagerDelegate>

@property (nonatomic, retain) Carl *carl;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) CLLocation *carlsCurrentDestination;

@end

@implementation CarlManager

@synthesize carl = _carl;
@synthesize locationManager = _locationManager;
@synthesize timer = _timer;
@synthesize carlsCurrentDestination = _carlsCurrentDestination;

- (void)startUpdatingUserLocataion
{
    // NSLocationAlwaysUsageDescription = "Carl is hungry, you don't want to be eaten sure, but at least give him a chance?"
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    #ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    #endif
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (void)updateCarlsETA
{
    // If Carl does not have a location yet let's place him on the map somewhere close. Should be 5-10 miles away from the user.
    
    if (self.carl.location == nil) {
        
        // For now we'll just add a bit to the coordinates.
        // TODO: Make proper distances and randomize them between the above started 5-10 miles.

        self.carl.location = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude + [LocationHelper latitudeFromMeters:4000] longitude:self.locationManager.location.coordinate.longitude + [LocationHelper longitudeFromMeters:4000]];
    }
    
    // Now Carl needs a destination, which is you!
    
    self.carlsCurrentDestination = self.locationManager.location;
    
    // Move Carl towards his destination.
    
    self.carl.location = [LocationHelper moveLocation:self.carl.location towardsLocation:self.carlsCurrentDestination meters:UPDATE_CARL_INTERVAL_SECONDS * CARL_METERS_PER_SECOND];
    
    CLLocationDistance metersApart = [self.carl.location distanceFromLocation:self.locationManager.location];
    CLLocationDistance metersNorth = [LocationHelper metersFromLatitude:self.carl.location.coordinate.latitude - self.locationManager.location.coordinate.latitude];
    CLLocationDistance metersEast = [LocationHelper metersFromLongitude:self.carl.location.coordinate.longitude - self.locationManager.location.coordinate.longitude];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CarlUpdatedDistanceFromUser" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:metersApart], @"metersApart", [NSNumber numberWithFloat:metersNorth], @"metersNorth", [NSNumber numberWithFloat:metersEast], @"metersEast", nil]];
}

#pragma mark Singleton Methods

+ (id)sharedCarlManager
{
    static CarlManager *sharedCarlManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCarlManager = [[self alloc] init];
    });
    return sharedCarlManager;
}

- (id)init
{
    if (self = [super init]) {
        self.carl = [[Carl alloc] init];
        self.carl.location = nil;
        
        [self startUpdatingUserLocataion];
        [self updateCarlsETA];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_CARL_INTERVAL_SECONDS target:(self) selector:@selector(updateCarlsETA) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark CLLocationManager Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //[locations lastObject];
    
    //NSLog(@"%@", [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserUpdatedHeading" object:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:newHeading.magneticHeading], @"newMagneticHeading", nil]];
}

@end
