//
//  RDAlertWindow.m
//  Stacked Alert
//
//  Created by Red Davis on 11/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDAlertWindow.h"
#import "REDAlertView.h"
#import "REDAlertViewController.h"

#import "CAAnimation+EasingEquations.h"

#import <QuartzCore/QuartzCore.h>


@interface REDAlertWindow ()

@end


@implementation REDAlertWindow

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelAlert;
        self.opaque = NO;
    }
    
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat colorLocations[2] = {0.0, 1.0};
    CGFloat colors[8] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorLocations, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(floorf(rect.size.width/2), floorf(rect.size.height/2));
    CGFloat radius = MIN(rect.size.width, rect.size.height);
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end
