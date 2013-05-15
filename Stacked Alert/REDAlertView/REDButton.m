//
//  RDSButton.m
//  Stacked Alert
//
//  Created by Red Davis on 17/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDButton.h"


@interface REDButton ()

@property (readonly, nonatomic) UIImage *backgroundImage;

- (void)setupStyles;
- (UIColor *)textColor;

@end


@implementation REDButton

#pragma mark - 

+ (id)buttonWithREDButtonType:(REDButtonType)buttonType
{    
    return [[REDButton alloc] initWithREDButtonType:buttonType];
}

#pragma mark - Initiaization

- (id)initWithREDButtonType:(REDButtonType)buttonType
{    
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        self.red_ButtonType = buttonType;
    }
    
    return self;
}

- (void)awakeFromNib
{    
    [self setupStyles];
}

#pragma mark -

- (void)setupStyles
{    
    [self setBackgroundImage:self.backgroundImage forState:UIControlStateNormal];
    [self setTitleColor:[self textColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    switch (self.red_ButtonType)
    {
        case REDButtonTypeLight:
        {
            [self setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.6] forState:UIControlStateNormal];
            self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
            break;
        }
        default:
            break;
    }
}

- (void)setRed_ButtonType:(REDButtonType)red_ButtonType
{
    if (_red_ButtonType == red_ButtonType)
        return;
    
    _red_ButtonType = red_ButtonType;
    [self setupStyles];
}

#pragma mark - Helpers

- (UIColor *)textColor
{
    UIColor *textColor = [UIColor whiteColor];
    switch (self.red_ButtonType)
    {
        case REDButtonTypeLight:
        {
            textColor = [UIColor colorWithRed:0.267 green:0.267 blue:0.267 alpha:1];
            break;
        }
        default:
            break;
    }
    
    return textColor;
}

- (UIImage *)backgroundImage
{
    UIImage *backgroundImage = nil;
    switch (self.red_ButtonType) {
        case REDButtonTypeLight:
            backgroundImage = [[UIImage imageNamed:@"ButtonLight"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0, 7.0, 20.0, 7.0)];
            break;
            
        case REDButtonTypeDark:
            backgroundImage = [[UIImage imageNamed:@"ButtonDark"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0, 7.0, 20.0, 7.0)];
            break;
        
        case REDButtonTypeBlue:
            backgroundImage = [[UIImage imageNamed:@"ButtonBlue"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0, 7.0, 20.0, 7.0)];
            break;
            
        case REDButtonTypeRed:
            backgroundImage = [[UIImage imageNamed:@"ButtonRed"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0, 7.0, 20.0, 7.0)];
            break;
        
        default:
            break;
    }
    
    return backgroundImage;
}

@end
