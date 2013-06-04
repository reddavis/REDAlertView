//
//  REDAlertViewController.m
//  Stacked Alert
//
//  Created by Red Davis on 04/06/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDAlertViewController.h"
#import "REDAlertView.h"
#import "REDAlertWindow.h"

#import "CAAnimation+EasingEquations.h"

#import <QuartzCore/QuartzCore.h>


@interface REDAlertViewController ()

@property (strong, nonatomic) REDAlertWindow *alertWindow;

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


@implementation REDAlertViewController

#pragma mark -

+ (instancetype)sharedAlertViewController
{
    static REDAlertViewController *sharedAlertViewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlertViewController = [[REDAlertViewController alloc] initWithNibName:nil bundle:nil];
                
        REDAlertWindow *alertWindow = [[REDAlertWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        alertWindow.rootViewController = sharedAlertViewController;
        sharedAlertViewController.alertWindow = alertWindow;
    });
    
    return sharedAlertViewController;
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.alertViews = [NSMutableArray array];
        self.animationQueue = [NSMutableArray array];
        self.gestureStartingPoints = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void)addAlert:(REDAlertView *)alertView completionBlock:(void (^)(void))block
{
    void(^animationBlock)(void) = ^{
        @synchronized(self.alertViews)
        {
            if (![self.alertWindow isKeyWindow])
            {
                self.alertWindow.originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
                self.alertWindow.hidden = NO;
                [self.alertWindow makeKeyAndVisible];
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
            [self.view addSubview:alertView];
            [alertView sizeToFit];
            
            alertView.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2.0 - CGRectGetWidth(alertView.bounds)/2.0, -alertView.frame.size.height, alertView.frame.size.width, alertView.frame.size.height);
            
            [CAAnimation addAnimationToLayer:alertView.layer withKeyPath:@"position.y" duration:0.5 to:CGRectGetHeight(self.view.bounds)/2 easingFunction:CAAnimationEasingFunctionEaseOutElastic completionBlock:^{
                                
                CGRect frame = alertView.frame;
                frame.origin.x = CGRectGetWidth(self.view.bounds)/2.0 - CGRectGetWidth(alertView.bounds)/2.0;
                frame.origin.y = CGRectGetHeight(self.view.bounds)/2.0 - CGRectGetHeight(alertView.bounds)/2.0;
                alertView.frame = frame;
                
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
    void(^animationBlock)(void) = ^{
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
                    [self.alertWindow.originalKeyWindow makeKeyAndVisible];
                    self.alertWindow.hidden = YES;
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
    void(^animationBlock)(void) = ^{
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
                        rect.origin.y = self.view.frame.size.height;
                        alertView.frame = rect;
                    } completion:^(BOOL finished) {
                        
                        [self.alertViews removeLastObject];
                        [alertView removeFromSuperview];
                        
                        if (!self.alertViews.count)
                        {
                            self.isProcessingAnimation = NO;
                            [self.alertWindow.originalKeyWindow makeKeyAndVisible];
                            self.alertWindow.hidden = YES;
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
    
    void(^animationBlock)(void) = [self.animationQueue objectAtIndex:0];
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
        
        CGPoint translatedPoint = [panGesture translationInView:self.view];
        CGPoint alertViewCenter = CGPointMake(startingPoint.x+translatedPoint.x, startingPoint.y+translatedPoint.y);
        alertView.center = alertViewCenter;
    }
    else
    {
        CGPoint velocity = [panGesture velocityInView:self.view];
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
            CGFloat scale = self.view.frame.size.height / sqrtf(xDifference * xDifference + yDifference * yDifference);
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

@end
