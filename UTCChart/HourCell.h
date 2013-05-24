//
//  HourCell.h
//  UTCChart
//
//  Created by Michael Luton on 11/20/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HourCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *localDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *localHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *utcDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *utcHourLabel;

@end
