//
//  SAViewController.m
//  Stacked Alert
//
//  Created by Red Davis on 08/01/2013.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import "SAViewController.h"
#import "REDAlertView.h"


@interface SAViewController ()

- (void)viewTappedGestureEngaged:(UITapGestureRecognizer *)gesture;

@end


static CGSize const kStackableViewSize = {175.0, 75.0};


@implementation SAViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTappedGestureEngaged:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Gestures

- (void)viewTappedGestureEngaged:(UITapGestureRecognizer *)gesture
{    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        REDAlertView *alert = [[REDAlertView alloc] initWithTitle:@"Error" message:@"There was an error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"1", nil];
        [alert show];
        
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            REDAlertView *alert2 = [[REDAlertView alloc] initWithTitle:@"Hello" message:@"Nice to meet you" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"2", nil];
            [alert2 show];
        });
        
        int64_t delayInSeconds2 = 2.0;
        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
            REDAlertView *alert3 = [[REDAlertView alloc] initWithTitle:@"Long message" message:@"This is a long message this is a long message this is a long message this is a long message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"3", nil];
            [alert3 show];
        });
    }
}

@end
