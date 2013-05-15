//
//  RDAlertWindow.m
//  Stacked Alert
//
//  Created by Red Davis on 11/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDAlertWindow.h"
#import "REDAlertView.h"

#import <QuartzCore/QuartzCore.h>


@interface REDAlertWindow ()

@property (strong, nonatomic) UIWindow *originalKeyWindow;
@property (strong, nonatomic) NSMutableArray *alertViews;

@end


//static CGSize const kAlertViewSize = {250.0, 150.0};


@implementation REDAlertWindow

#pragma mark -

+ (REDAlertWindow *)mainWindow
{    
    static REDAlertWindow *mainWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainWindow = [[REDAlertWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    
    return mainWindow;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.alertViews = [NSMutableArray array];
        
        self.windowLevel = UIWindowLevelAlert;
        self.rootViewController = [[UIViewController alloc] init];
        self.opaque = NO;
    }
    
    return self;
}

#pragma mark -

- (void)addAlert:(REDAlertView *)alertView
{        
    @synchronized(self.alertViews)
    {
        if (![self isKeyWindow])
        {
            self.originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
            self.hidden = NO;
            [self makeKeyAndVisible];
        }
        
        CGFloat animationDelay = 0.0;
        CGFloat animationDelayIncrement = 0.2;
        for (UIView *stackedView in self.alertViews)
        {
            [UIView animateWithDuration:animationDelayIncrement delay:animationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                stackedView.frame = CGRectOffset(stackedView.frame, 0.0, -CGRectGetHeight(stackedView.frame)*0.2);
                stackedView.transform = CGAffineTransformScale(stackedView.transform, 0.8, 0.8);
            } completion:^(BOOL finished) {
                
            }];
            
            animationDelay += animationDelayIncrement;
        }
        
        [self.alertViews addObject:alertView];
        [self addSubview:alertView];
        [alertView sizeToFit];
        
        alertView.frame = CGRectMake(0.0, -alertView.frame.size.height, alertView.frame.size.width, alertView.frame.size.height);
        alertView.center = CGPointMake(CGRectGetWidth(self.frame)/2, alertView.center.y);
                
        [UIView animateWithDuration:animationDelayIncrement delay:animationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            alertView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)removeAlert:(REDAlertView *)alertView
{
    // TODO: animation for removing an alert view in the middle of the stack
    UIView *topView = [self.alertViews lastObject];
    if (alertView == topView)
        [self popAlertFromStack];
}

- (void)popAlertFromStack
{    
    @synchronized(self.alertViews)
    {
        UIView *topView = [self.alertViews lastObject];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            topView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [topView removeFromSuperview];
            [self.alertViews removeLastObject];
            
            
            CGFloat animationDelay = 0.0;
            CGFloat animationDelayIncrement = 0.2;
            for (UIView *alertView in [self.alertViews reverseObjectEnumerator])
            {
                [UIView animateWithDuration:0.3 delay:animationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    alertView.frame = CGRectOffset(alertView.frame, 0.0, CGRectGetHeight(alertView.frame)*0.2);
                    alertView.transform = CGAffineTransformScale(alertView.transform, 1.0/0.8, 1.0/0.8);
                } completion:^(BOOL finished) {
                
                }];
                
                animationDelay += animationDelayIncrement;
            }
            
            if (!self.alertViews.count)
            {
                [self.originalKeyWindow makeKeyAndVisible];
                self.hidden = YES;
            }
        }];
    }
}

#pragma mark - Helpers

- (UIColor *)randomColor
{    
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{    
    [super drawRect:rect];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    NSArray *colours = @[(id)[UIColor colorWithWhite:1.0 alpha:0.7].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.7].CGColor];
//    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colours, NULL);
//    
//    CGPoint startPoint = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2);
//        
//    CGContextDrawRadialGradient(context, gradient, startPoint, 0.0, startPoint, CGRectGetWidth(rect), 0);
//    CGGradientRelease(gradient);
}

@end
