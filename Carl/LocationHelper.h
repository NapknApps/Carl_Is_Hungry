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

+ (CLLocation *)moveLocation:(CLLocation *)location1 towardsLocation:(CLLocation *)location2 meters:(int)meters;
+ (float)latitudeFromMeters:(int)meters;
+ (float)longitudeFromMeters:(int)meters;
+ (int)metersFromLatitude:(float)latitude;
+ (int)metersFromLongitude:(float)longitude;

@end
