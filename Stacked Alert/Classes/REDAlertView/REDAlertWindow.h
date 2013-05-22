//
//  RDAlertWindow.h
//  Stacked Alert
//
//  Created by Red Davis on 11/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import <UIKit/UIKit.h>


@class REDAlertView;


@interface REDAlertWindow : UIWindow

+ (REDAlertWindow *)mainWindow;

- (void)addAlert:(REDAlertView *)alertView completionBlock:(void (^)(void))block;
- (void)removeAlert:(REDAlertView *)alertView;

@end
