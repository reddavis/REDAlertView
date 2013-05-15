//
//  RDSButton.h
//  Stacked Alert
//
//  Created by Red Davis on 17/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, REDButtonType) {
    REDButtonTypeUnknown,
    REDButtonTypeLight,
    REDButtonTypeDark,
    REDButtonTypeBlue,
    REDButtonTypeRed
};


@interface REDButton : UIButton

@property (assign, nonatomic) REDButtonType red_ButtonType;

+ (id)buttonWithREDButtonType:(REDButtonType)buttonType;
- (id)initWithREDButtonType:(REDButtonType)buttonType;

@end
