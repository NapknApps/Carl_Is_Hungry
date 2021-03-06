//
//  Carl.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "Carl.h"

@implementation Carl

- (void)setLatitude:(float)latitude longitude:(float)longitude
{
    if (latitude != 0.0 && longitude != 0.0) {
        NSDictionary *locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:latitude], @"latitude", [NSNumber numberWithFloat:longitude], @"longitude", nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:locationDict forKey:@"carlsLocation"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"carlLastMoved"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CLLocation *)location
{
    NSDictionary *locationDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"carlsLocation"];
    if (locationDict) {

        return [[CLLocation alloc] initWithLatitude:[[locationDict valueForKey:@"latitude"] floatValue] longitude:[[locationDict valueForKey:@"longitude"] floatValue]];
    }
    else {
        return nil;
    }
}

- (NSDate *)lastMoved
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"carlLastMoved"];
}

@end
