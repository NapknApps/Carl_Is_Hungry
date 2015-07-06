//
//  Carl.h
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Carl : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) CLLocation *location;

@end
