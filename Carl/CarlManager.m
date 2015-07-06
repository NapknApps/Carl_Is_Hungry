//
//  CarlManager.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "CarlManager.h"

@implementation CarlManager

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
    }
    return self;
}

@end
