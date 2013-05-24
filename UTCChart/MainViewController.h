//
//  MainViewController.h
//  UTCChart
//
//  Created by Michael Luton on 11/19/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
