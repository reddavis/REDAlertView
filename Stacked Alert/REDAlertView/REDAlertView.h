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

@property (weak, nonatomic) id <REDStackedAlertViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (void)show;

@end


@protocol REDStackedAlertViewDelegate <NSObject>
@optional

@end
