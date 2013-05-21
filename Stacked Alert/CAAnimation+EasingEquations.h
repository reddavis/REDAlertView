//
//  CAAnimation+EasingEquations.h
//  OKEasingFunctions
//
//  Created by Bryan Oltman on 12/18/12.
//  Copyright (c) 2012 Bryan Oltman. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSInteger, CAAnimationEasingFunction) {
    CAAnimationEasingFunctionEaseInQuad,
    CAAnimationEasingFunctionEaseOutQuad,
    CAAnimationEasingFunctionEaseInOutQuad,
    
    CAAnimationEasingFunctionEaseInCubic,
    CAAnimationEasingFunctionEaseOutCubic,
    CAAnimationEasingFunctionEaseInOutCubic,
    
    CAAnimationEasingFunctionEaseInQuartic,
    CAAnimationEasingFunctionEaseOutQuartic,
    CAAnimationEasingFunctionEaseInOutQuartic,

    CAAnimationEasingFunctionEaseInQuintic,
    CAAnimationEasingFunctionEaseOutQuintic,
    CAAnimationEasingFunctionEaseInOutQuintic,

    CAAnimationEasingFunctionEaseInSine,
    CAAnimationEasingFunctionEaseOutSine,
    CAAnimationEasingFunctionEaseInOutSine,

    CAAnimationEasingFunctionEaseInExponential,
    CAAnimationEasingFunctionEaseOutExponential,
    CAAnimationEasingFunctionEaseInOutExponential,

    CAAnimationEasingFunctionEaseInCircular,
    CAAnimationEasingFunctionEaseOutCircular,
    CAAnimationEasingFunctionEaseInOutCircular,

    CAAnimationEasingFunctionEaseInElastic,
    CAAnimationEasingFunctionEaseOutElastic,
    CAAnimationEasingFunctionEaseInOutElastic,
    
    CAAnimationEasingFunctionEaseInBack,
    CAAnimationEasingFunctionEaseOutBack,
    CAAnimationEasingFunctionEaseInOutBack,

    CAAnimationEasingFunctionEaseInBounce,
    CAAnimationEasingFunctionEaseOutBounce,
    CAAnimationEasingFunctionEaseInOutBounce
};

typedef void(^CAAnimationCompletionBlock)(void);


@interface CAAnimation (EasingEquations)

@property (copy, nonatomic) CAAnimationCompletionBlock completionBlock;

+ (CAKeyframeAnimation*)animationWithKeyPath:(NSString *)keyPath duration:(CGFloat)duration from:(CGFloat)startValue to:(CGFloat)endValue easingFunction:(CAAnimationEasingFunction)easingFunction completionBlock:(CAAnimationCompletionBlock)block;

+ (void)addAnimationToLayer:(CALayer *)layer withKeyPath:(NSString *)keyPath duration:(CGFloat)duration to:(CGFloat)endValue easingFunction:(CAAnimationEasingFunction)easingFunction completionBlock:(CAAnimationCompletionBlock)block;

+ (void)addAnimationToLayer:(CALayer *)layer withKeyPath:(NSString *)keyPath duration:(CGFloat)duration from:(CGFloat)startValue to:(CGFloat)endValue easingFunction:(CAAnimationEasingFunction)easingFunction completionBlock:(CAAnimationCompletionBlock)block;
@end
