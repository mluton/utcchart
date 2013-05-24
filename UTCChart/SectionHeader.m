//
//  SectionHeader.m
//  UTCChart
//
//  Created by Michael Luton on 11/20/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import "SectionHeader.h"

@interface SectionHeader()

- (IBAction)infoButtonPressed;

@end

@implementation SectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)infoButtonPressed
{
    [self.delegate infoButtonPressed];
}

@end
