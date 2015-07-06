//
//  LocationHelper.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

+ (CLLocation *)moveLocation:(CLLocation *)location1 towardsLocation:(CLLocation *)location2 meters:(int)meters
{
    // TODO: Make sure the new location doesn't overshoot its target.
    // TODO: The meters aren't actually accurate, need some help from Pythagoras.

    CLLocationDegrees newLatitude;
    CLLocationDegrees newLongitude;
    
    if (location1.coordinate.latitude < location2.coordinate.latitude) {
        newLatitude = location1.coordinate.latitude + [self latitudeFromMeters:meters];
    }
    else {
        newLatitude = location1.coordinate.latitude - [self latitudeFromMeters:meters];
    }
    
    if (location1.coordinate.longitude < location2.coordinate.longitude) {
        newLongitude = location1.coordinate.longitude + [self longitudeFromMeters:meters];
    }
    else {
        newLongitude = location1.coordinate.longitude - [self longitudeFromMeters:meters];
    }
    
    return [[CLLocation alloc] initWithLatitude:newLatitude longitude:newLongitude];
}

+ (float)latitudeFromMeters:(int)meters
{
    // TODO: Check accuracy of below.
    // 1 latitude = 110575 meters, http://msi.nga.mil/MSISiteContent/StaticFiles/Calculators/degree.html
    
    return meters / 110575.0;
}

+ (float)longitudeFromMeters:(int)meters
{
    // TODO: Check accuracy of below.
    // 1 longitude = 111303 meters, http://msi.nga.mil/MSISiteContent/StaticFiles/Calculators/degree.html
    
    return meters / 111303.0;
}

@end
