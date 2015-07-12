//
//  User.m
//  Carl
//
//  Created by Zach Whelchel on 7/8/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "User.h"

@implementation User

- (void)setLatitude:(float)latitude longitude:(float)longitude
{
    if (latitude != 0.0 && longitude != 0.0) {
        NSDictionary *locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:latitude], @"latitude", [NSNumber numberWithFloat:longitude], @"longitude", nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:locationDict forKey:@"usersLocation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CLLocation *)location
{
    NSDictionary *locationDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"usersLocation"];
    
    if (locationDict) {
        return [[CLLocation alloc] initWithLatitude:[[locationDict valueForKey:@"latitude"] floatValue] longitude:[[locationDict valueForKey:@"longitude"] floatValue]];
    }
    else {
        return nil;
    }
}

@end
