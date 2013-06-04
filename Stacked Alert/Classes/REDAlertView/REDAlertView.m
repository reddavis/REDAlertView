//
//  RDStackedAlertView.m
//  Stacked Alert
//
//  Created by Red Davis on 08/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "REDAlertView.h"
#import "REDAlertViewController.h"
#import "REDButton.h"

#import <QuartzCore/QuartzCore.h>


@interface REDAlertView ()

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *cancelButtonTitle;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic) CGFloat calculatedHeight;

- (void)setupLabels;
- (UILabel *)buildLabel;

- (void)buttonTapped:(id)sender;

@end


static CGFloat const kAlertViewWidth = 250.0;
static CGFloat const kAlertViewMinHeight = 163.0;
static CGSize const kSmallButtonSize = {90.0, 40.0};
static CGSize const kLargeButtonSize = {200.0, 40.0};

static CGFloat const kMessageLabelRightLeftPadding = 6.0;
static CGFloat const kButtonPaddingFromCenter = 6.0;
static CGFloat const kButtonTopBottomPadding = 8.0;


@implementation REDAlertView

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{    
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 4.0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.layer.shadowOpacity = 0.30;
        
        self.title = title;
        self.message = message;
        self.cancelButtonTitle = cancelButtonTitle;
        self.buttons = [NSMutableArray array];
        
        [self setupLabels];
        
        // Buttons
        REDButton *cancelButton = [REDButton buttonWithREDButtonType:REDButtonTypeLight];
        [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [self.buttons addObject:cancelButton];
        
        va_list args;
        va_start(args, otherButtonTitles);
        NSString *argString = otherButtonTitles;
        while (argString != nil)
        {
            REDButton *button = [REDButton buttonWithREDButtonType:REDButtonTypeLight];
            [button setTitle:argString forState:UIControlStateNormal];
            [self.buttons addObject:button];
            
            argString = va_arg(args, NSString *);
        }
        va_end(args);
        
        for (REDButton *button in self.buttons)
        {
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    
    return self;
}

#pragma mark - View Setup

- (void)layoutSubviews
{
    self.calculatedHeight = 0.0;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    CGSize titleLabelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    self.titleLabel.frame = CGRectMake(0.0, 20.0, kAlertViewWidth, titleLabelSize.height);
    
    CGSize constrainedMessageLabelSize = CGSizeMake(kAlertViewWidth - (kMessageLabelRightLeftPadding*2), MAXFLOAT);
    CGSize messageLabelSize = [self.message sizeWithFont:self.messageLabel.font constrainedToSize:constrainedMessageLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    self.messageLabel.frame = CGRectMake(kMessageLabelRightLeftPadding, CGRectGetMaxY(self.titleLabel.frame)+8.0, kAlertViewWidth-kMessageLabelRightLeftPadding*2, messageLabelSize.height);
    
    if (self.buttons.count == 1)
    {
        CGSize buttonSize = kLargeButtonSize;
        CGFloat yCoor = CGRectGetMaxY(self.messageLabel.frame) + kButtonTopBottomPadding;
        REDButton *button = [self.buttons objectAtIndex:0];
        button.frame = CGRectMake(0.0, yCoor, buttonSize.width, buttonSize.height);
        
        self.calculatedHeight = CGRectGetMaxY(button.frame) + kButtonTopBottomPadding;
    }
    else if (self.buttons.count == 2)
    {
        CGSize buttonSize = kSmallButtonSize;
        CGFloat centerXCoor = floorf(self.bounds.size.width/2.0);
        REDButton *leftButton = [self.buttons objectAtIndex:0];
        REDButton *rightButton = [self.buttons lastObject];
        
        CGFloat yCoor = CGRectGetMaxY(self.messageLabel.frame) + kButtonTopBottomPadding;
        leftButton.frame = CGRectMake(centerXCoor-buttonSize.width-kButtonPaddingFromCenter, yCoor, buttonSize.width, buttonSize.height);
        rightButton.frame = CGRectMake(centerXCoor+kButtonPaddingFromCenter, yCoor, buttonSize.width, buttonSize.height);
        
        self.calculatedHeight = CGRectGetMaxY(leftButton.frame) + kButtonTopBottomPadding;
    }
    else
    {
        CGFloat centerXCoor = floorf(self.bounds.size.width/2.0);
        CGFloat yCoor = CGRectGetMaxY(self.messageLabel.frame) + kButtonTopBottomPadding;
        CGFloat xCoor = centerXCoor - (kLargeButtonSize.width/2.0);
        for (REDButton *button in self.buttons)
        {
            button.frame = CGRectMake(xCoor, yCoor, kLargeButtonSize.width, kLargeButtonSize.height);
            yCoor += kLargeButtonSize.height + kButtonTopBottomPadding;
            self.calculatedHeight = yCoor;
        }
    }
}

- (void)setupLabels
{    
    self.titleLabel = [self buildLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.text = self.title;
    [self addSubview:self.titleLabel];
    
    self.messageLabel = [self buildLabel];
    self.messageLabel.font = [UIFont systemFontOfSize:16];
    self.messageLabel.text = self.message;
    self.messageLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:self.messageLabel];
}

#pragma mark -

- (void)show
{
    __weak typeof(self) weakSelf = self;
    if (self.willPresentBlock)
        self.willPresentBlock(weakSelf);
    
    [[REDAlertViewController sharedAlertViewController] addAlert:self completionBlock:^{
        if (self.didPresentBlock)
            self.didPresentBlock(weakSelf);
    }];
}

#pragma mark - Actions

- (void)buttonTapped:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if (self.willDismissBlock)
        self.willDismissBlock(weakSelf);
    
    if (self.clickedButtonBlock)
    {
        NSInteger buttonIndex = [self.buttons indexOfObject:sender];
        self.clickedButtonBlock(buttonIndex);
    }
    
    [[REDAlertViewController sharedAlertViewController] removeAlert:self];
}

#pragma mark -

- (void)sizeToFit
{
    [self layoutSubviews];
    CGRect frame = self.frame;
    frame.size.width = kAlertViewWidth;
    frame.size.height = self.calculatedHeight;
    self.frame = frame;
}

#pragma mark - Helpers

- (UILabel *)buildLabel
{    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

@end
