//
//  User.h
//  Carl
//
//  Created by Zach Whelchel on 7/8/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject

- (void)setLatitude:(float)latitude longitude:(float)longitude;
- (CLLocation *)location;

@end
