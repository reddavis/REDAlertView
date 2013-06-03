//
//  RDAlertWindow.m
//  Stacked Alert
//
//  Created by Red Davis on 11/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDAlertWindow.h"
#import "REDAlertView.h"

#import "CAAnimation+EasingEquations.h"

#import <QuartzCore/QuartzCore.h>


@interface REDAlertWindow ()

@property (strong, nonatomic) UIWindow *originalKeyWindow;
@property (strong, nonatomic) NSMutableArray *alertViews;
@property (strong, nonatomic) NSMutableArray *animationQueue;
@property (assign, nonatomic) BOOL isProcessingAnimation;
@property (strong, nonatomic) NSMutableDictionary *gestureStartingPoints;

- (void)processNextAnimation;
- (void)popAlertFromStack;
- (void)dismissAllAlerts;
- (BOOL)isTopAlertView:(REDAlertView *)alertView;
- (void)alertViewPanGestureEngadged:(UIGestureRecognizer *)gesture;

@end


typedef void(^REDAlertAnimationBlock)(void);


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
        self.gestureStartingPoints = [NSMutableDictionary dictionary];
        self.animationQueue = [NSMutableArray array];
        self.alertViews = [NSMutableArray array];
        
        self.windowLevel = UIWindowLevelAlert;
        self.rootViewController = [[UIViewController alloc] init];
        self.opaque = NO;
    }
    
    return self;
}

#pragma mark -

- (void)addAlert:(REDAlertView *)alertView completionBlock:(void (^)(void))block
{
    REDAlertAnimationBlock animationBlock = ^{
        @synchronized(self.alertViews)
        {
            if (![self isKeyWindow])
            {
                self.originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
                self.hidden = NO;
                [self makeKeyAndVisible];
            }
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(alertViewPanGestureEngadged:)];
            [alertView addGestureRecognizer:panGesture];
            alertView.tag = self.alertViews.count;
            
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
            
            [CAAnimation addAnimationToLayer:alertView.layer withKeyPath:@"position.y" duration:0.5 to:CGRectGetHeight(self.frame)/2 easingFunction:CAAnimationEasingFunctionEaseOutElastic completionBlock:^{
                
                alertView.center = self.center;
                [alertView.layer removeAllAnimations];
                
                if (block)
                    block();
                
                self.isProcessingAnimation = NO;
                [self processNextAnimation];
            }];
        }
    };
    
    [self.animationQueue addObject:animationBlock];
    
    if (!self.isProcessingAnimation)
        [self processNextAnimation];
}

- (void)removeAlert:(REDAlertView *)alertView
{
    if ([self isTopAlertView:alertView])
        [self popAlertFromStack];
}

- (void)popAlertFromStack
{
    REDAlertAnimationBlock animationBlock = ^{
        @synchronized(self.alertViews)
        {
            UIView *topView = [self.alertViews lastObject];
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                topView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [topView removeFromSuperview];
                [self.alertViews removeLastObject];
                
                CGFloat animationDelay = 0.0;
                CGFloat animationDuration = 0.2;
                
                for (REDAlertView *alertView in [self.alertViews reverseObjectEnumerator])
                {
                    [UIView animateWithDuration:animationDuration delay:animationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        alertView.frame = CGRectOffset(alertView.frame, 0.0, CGRectGetHeight(alertView.frame)*0.2);
                        alertView.transform = CGAffineTransformScale(alertView.transform, 1.0/0.8, 1.0/0.8);
                    } completion:^(BOOL finished) {
                        if (alertView == [self.alertViews objectAtIndex:0])
                        {
                            self.isProcessingAnimation = NO;
                            [self processNextAnimation];
                        }
                    }];
                    
                    animationDelay += animationDuration;
                };
                
                if (!self.alertViews.count)
                {
                    self.isProcessingAnimation = NO;
                    [self.originalKeyWindow makeKeyAndVisible];
                    self.hidden = YES;
                }
            }];
        }
    };
    
    [self.animationQueue addObject:animationBlock];
    
    if (!self.isProcessingAnimation)
        [self processNextAnimation];
}

- (void)dismissAllAlerts
{
    REDAlertAnimationBlock animationBlock = ^{
        @synchronized(self.alertViews)
        {
            CGFloat animationDelay = 0.0;
            CGFloat animationDuration = 0.20;
            
            for (REDAlertView *alertView in [self.alertViews reverseObjectEnumerator])
            {
                [UIView animateWithDuration:animationDuration delay:animationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CGRect rect = alertView.frame;
                    rect.origin.y -= 15.0;
                    alertView.frame = rect;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                        CGRect rect = alertView.frame;
                        rect.origin.y = self.frame.size.height;
                        alertView.frame = rect;
                    } completion:^(BOOL finished) {
                        
                        [self.alertViews removeLastObject];
                        [alertView removeFromSuperview];
                        
                        if (!self.alertViews.count)
                        {
                            self.isProcessingAnimation = NO;
                            [self.originalKeyWindow makeKeyAndVisible];
                            self.hidden = YES;
                        }
                    }];
                }];
                
                animationDelay += animationDuration;
            };
        }
    };
    
    [self.animationQueue addObject:animationBlock];
    
    if (!self.isProcessingAnimation)
        [self processNextAnimation];
}

#pragma mark - Animation Processing

- (void)processNextAnimation
{
    if (self.animationQueue.count == 0)
        return;
    
    REDAlertAnimationBlock animationBlock = [self.animationQueue objectAtIndex:0];
    [self.animationQueue removeObjectAtIndex:0];
    
    self.isProcessingAnimation = YES;
    animationBlock();
}

#pragma mark - Gestures

- (void)alertViewPanGestureEngadged:(UIGestureRecognizer *)gesture
{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    REDAlertView *alertView = (REDAlertView *)gesture.view;
        
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        [self.gestureStartingPoints setObject:[NSValue valueWithCGPoint:alertView.center] forKey:@(alertView.tag)];
        self.isProcessingAnimation = YES;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        NSValue *startingPointValue = [self.gestureStartingPoints objectForKey:@(alertView.tag)];
        CGPoint startingPoint = [startingPointValue CGPointValue];
        
        CGPoint translatedPoint = [panGesture translationInView:self];
        CGPoint alertViewCenter = CGPointMake(startingPoint.x+translatedPoint.x, startingPoint.y+translatedPoint.y);
        alertView.center = alertViewCenter;
    }
    else
    {
        CGPoint velocity = [panGesture velocityInView:self];
        CGFloat xVelocity = abs(velocity.x);
        CGFloat yVelocity = abs(velocity.y);
        
        NSValue *startingPointValue = [self.gestureStartingPoints objectForKey:@(alertView.tag)];
        CGPoint startingPoint = [startingPointValue CGPointValue];
        CGPoint endPoint = alertView.center;
                
        static CGFloat const kPopAlertViewThrowThreshold = 2000.0;
        BOOL popAlertView = (xVelocity > kPopAlertViewThrowThreshold || yVelocity > kPopAlertViewThrowThreshold) && [self isTopAlertView:alertView];
        if (popAlertView)
        {
            // Calculate trajectory
            CGFloat xDifference = endPoint.x - startingPoint.x;
            CGFloat yDifference = endPoint.y - startingPoint.y;
            CGFloat scale = self.frame.size.height / sqrtf(xDifference * xDifference + yDifference * yDifference);
            CGPoint projectedPosition = CGPointMake(startingPoint.x + xDifference * scale, startingPoint.y + yDifference * scale);
                        
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                alertView.center = projectedPosition;
            } completion:^(BOOL finished) {
                self.isProcessingAnimation = NO;
                [self popAlertFromStack];
            }];
        }
        else
        {            
            [CAAnimation addAnimationToLayer:alertView.layer withKeyPath:@"position.x" duration:0.5 to:startingPoint.x easingFunction:CAAnimationEasingFunctionEaseOutElastic completionBlock:nil];
            
            [CAAnimation addAnimationToLayer:alertView.layer withKeyPath:@"position.y" duration:0.5 to:startingPoint.y easingFunction:CAAnimationEasingFunctionEaseOutElastic completionBlock:^{
                
                alertView.center = startingPoint;
                [alertView.layer removeAllAnimations];
                
                self.isProcessingAnimation = NO;
                [self processNextAnimation];
            }];
        }
        
        [self.gestureStartingPoints removeObjectForKey:@(alertView.tag)];
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
        [self dismissAllAlerts];
}

#pragma mark - Helpers

- (BOOL)isTopAlertView:(REDAlertView *)alertView
{
    UIView *topView = [self.alertViews lastObject];
    return (alertView == topView);
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
