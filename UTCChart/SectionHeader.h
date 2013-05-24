//
//  SectionHeader.h
//  UTCChart
//
//  Created by Michael Luton on 11/20/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectionHeaderDelegate <NSObject>
- (void)infoButtonPressed;
@end

@interface SectionHeader : UIView

@property (nonatomic, weak) id <SectionHeaderDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *localTimeZoneLabel;


@end
