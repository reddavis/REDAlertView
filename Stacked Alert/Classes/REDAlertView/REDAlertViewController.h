//
//  REDAlertViewController.h
//  Stacked Alert
//
//  Created by Red Davis on 04/06/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import <UIKit/UIKit.h>


@class REDAlertWindow;
@class REDAlertView;


@interface REDAlertViewController : UIViewController

+ (instancetype)sharedAlertViewController;

- (void)addAlert:(REDAlertView *)alertView completionBlock:(void (^)(void))block;
- (void)removeAlert:(REDAlertView *)alertView;

@end
