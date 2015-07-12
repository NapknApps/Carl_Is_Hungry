//
//  LocationHelper.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

+ (CLLocation *)moveLocation:(CLLocation *)location1 towardsLocation:(CLLocation *)location2 meters:(float)meters
{
    // Can overshoot its target. This isnt ideal, but will work still.
    // The meters aren't actually accurate, need some help from Pythagoras.

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

+ (float)latitudeFromMeters:(float)meters
{
    // 1 latitude = 110575 meters, http://msi.nga.mil/MSISiteContent/StaticFiles/Calculators/degree.html
    return meters / 110575.0;
}

+ (float)longitudeFromMeters:(float)meters
{
    // 1 longitude = 111303 meters, http://msi.nga.mil/MSISiteContent/StaticFiles/Calculators/degree.html
    return meters / 111303.0;
}

+ (int)metersFromLatitude:(float)latitude
{
    return latitude * 110575.0;
}

+ (int)metersFromLongitude:(float)longitude
{
    return longitude * 111303.0;
}

+ (int)randomMetersCountBetweenWithMinMeters:(int)minMeters maxMeters:(int)maxMeters
{
    int i = minMeters + arc4random() % (maxMeters - minMeters);
    if (arc4random_uniform(100) <= 50) {
        i = i * -1;
    }
    
    return i;
}

+ (float)latitudeDifferenceNorthInMetersBetweenLocation1:(CLLocation *)location1 location2:(CLLocation *)location2
{
    CLLocation *newLocation1 = [[CLLocation alloc] initWithLatitude:location1.coordinate.latitude longitude:0];
    CLLocation *newLocation2 = [[CLLocation alloc] initWithLatitude:location2.coordinate.latitude longitude:0];

    float metersApart = [newLocation1 distanceFromLocation:newLocation2];

    if (location1.coordinate.latitude < location2.coordinate.latitude) {
        metersApart = metersApart * -1;
    }

    return metersApart;
}

+ (float)longitudeDifferenceEastInMetersBetweenLocation1:(CLLocation *)location1 location2:(CLLocation *)location2
{
    CLLocation *newLocation1 = [[CLLocation alloc] initWithLatitude:0 longitude:location1.coordinate.longitude];
    CLLocation *newLocation2 = [[CLLocation alloc] initWithLatitude:0 longitude:location2.coordinate.longitude];
    
    float metersApart = [newLocation1 distanceFromLocation:newLocation2];
    
    if (location1.coordinate.longitude < location2.coordinate.longitude) {
        metersApart = metersApart * -1;
    }

    return metersApart;
}

@end
