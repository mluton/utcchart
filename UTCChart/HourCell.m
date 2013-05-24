//
//  HourCell.m
//  UTCChart
//
//  Created by Michael Luton on 11/20/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import "HourCell.h"

@implementation HourCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
