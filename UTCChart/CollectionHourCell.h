//
//  CollectionHourCell.h
//  UTCChart
//
//  Created by Michael Luton on 1/25/13.
//  Copyright (c) 2013 Sandmoose Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionHourCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *localDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *localHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *utcDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *utcHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeZoneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceContraint;

@end
