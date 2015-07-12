//
//  LocationsManager.h
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    UpdateNone = 0,
    UpdateForeground,
    UpdateBackground
} UpdateMode;

typedef enum {
    Unknown = 0,
    Safe,
    UnderAttack,
    Eaten,
    Running
} UserStatus;

@interface LocationsManager : NSObject

@property (nonatomic) UpdateMode updateMode;
@property (nonatomic) UserStatus userStatus;

@property (nonatomic, retain) NSNumber *metersBetweenUserAndCarl;
@property (nonatomic, retain) NSNumber *metersCarlIsNorthOfUser;
@property (nonatomic, retain) NSNumber *metersCarlIsEastOfUser;
@property (nonatomic, retain) NSNumber *userHeading;
@property (nonatomic, retain) NSNumber *metersFromRunningStartLocation;

+ (id)sharedLocationsManager;

- (void)startUpdatingUserStatusForeground;
- (void)startUpdatingUserStatusBackground;
- (void)relocateCarl;
- (void)relocateCarlFromSleep;
- (BOOL)canSleep;
- (void)startRunning;
- (void)relocateCarlCloseForTesting;

@end
