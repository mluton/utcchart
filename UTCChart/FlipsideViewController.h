//
//  FlipsideViewController.h
//  UTCChart
//
//  Created by Michael Luton on 11/19/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray* products;
@property (assign, nonatomic) BOOL *adsRemoved;

- (IBAction)done:(id)sender;

@end
