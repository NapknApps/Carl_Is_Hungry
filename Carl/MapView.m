//
//  MapView.m
//  Carl
//
//  Created by Zach Whelchel on 7/7/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "MapView.h"

@implementation MapView

- (void)drawRect:(CGRect)rect
{
    float startAlpha = .1;
    float endAlpha = .5;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:startAlpha].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    // Assumes height larger then width.
    
    CGRect circle = CGRectMake(0 - (rect.size.height / 2) + (rect.size.width / 2), 0, rect.size.height, rect.size.height);
    CGContextSetLineWidth(context, 3);
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, circle);
    CGContextDrawPath(context, kCGPathFillStroke);

    int numOfRings = 5;
    
    float alphaIncrease = (endAlpha - startAlpha) / numOfRings;
    
    for (int i = 1; i < numOfRings; i++) {
        
        CGRect nextCircle = CGRectInset(circle, rect.size.height / (numOfRings * 2), rect.size.height / (numOfRings * 2));
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:startAlpha + (alphaIncrease * i)].CGColor);
        CGContextBeginPath(context);
        CGContextAddEllipseInRect(context, nextCircle);
        CGContextDrawPath(context, kCGPathFillStroke);

        circle = nextCircle;
    }

    UIGraphicsEndImageContext();
}

@end
