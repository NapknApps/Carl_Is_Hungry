//
//  LocationHelper.h
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject

+ (CLLocation *)moveLocation:(CLLocation *)location1 towardsLocation:(CLLocation *)location2 meters:(float)meters;
+ (float)latitudeFromMeters:(float)meters;
+ (float)longitudeFromMeters:(float)meters;
+ (int)metersFromLatitude:(float)latitude;
+ (int)metersFromLongitude:(float)longitude;
+ (int)randomMetersCountBetweenWithMinMeters:(int)minMeters maxMeters:(int)maxMeters;
+ (float)latitudeDifferenceNorthInMetersBetweenLocation1:(CLLocation *)location1 location2:(CLLocation *)location2;
+ (float)longitudeDifferenceEastInMetersBetweenLocation1:(CLLocation *)location1 location2:(CLLocation *)location2;

@end
