//
//  RDStackedAlertView.h
//  Stacked Alert
//
//  Created by Red Davis on 08/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol REDStackedAlertViewDelegate;


@interface REDAlertView : UIView

@property (copy, nonatomic) void(^clickedButtonBlock)(NSInteger buttonIndex);
@property (copy, nonatomic) void(^willDismissBlock)(NSInteger buttonIndex);
@property (copy, nonatomic) void(^didDismissBlock)(NSInteger buttonIndex);
@property (copy, nonatomic) void(^willPresentBlock)(REDAlertView *alertView);
@property (copy, nonatomic) void(^didPresentBlock)(REDAlertView *alertView);
@property (copy, nonatomic) void(^cancelBlock)(REDAlertView *alertView);

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (void)show;

@end
