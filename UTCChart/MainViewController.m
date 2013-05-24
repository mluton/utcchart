//
//  MainViewController.m
//  UTCChart
//
//  Created by Michael Luton on 11/19/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import <iAd/iAd.h>
#import "MainViewController.h"
#import "SectionHeader.h"
#import "HourCell.h"
#import "CollectionHourCell.h"
#import "MPLIAPGateway.h"

#define SECONDS_PER_HOUR 3600
#define COLLECTION_VIEW_TOP 44

@interface MainViewController () <SectionHeaderDelegate, ADBannerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *hours;
@property (strong, nonatomic) NSString *localTimeZone;
@property (assign, nonatomic) BOOL isShowingAd;
@property (assign, nonatomic) BOOL adsEnabled;
@property (strong, nonatomic) ADBannerView *bannerView;
@property (strong, nonatomic) NSArray* products;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchIAPProducts];
    [self setLocalTimeZoneString];
    [self styleTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.hours = [self populateHours];
    [self.tableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Force the UICollectionViewDelegateFlowLayout methods to be called on
    // device rotation so the layout confoms to the current orientation.
    [self.collectionView reloadData];
    
    // Fade ad banner out of view during rotation.
    [UIView animateWithDuration:0.15 animations:^{
        self.bannerView.alpha = 0;
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Set the new position and size of the ad banner.
    CGSize newBannerSize = [self.bannerView sizeThatFits:self.view.bounds.size];
    int y = self.isShowingAd ? self.view.bounds.size.height - self.bannerView.frame.size.height : self.view.frame.size.height;
    CGRect newBannerFrame = CGRectMake(self.bannerView.frame.origin.x, y, newBannerSize.width, self.bannerView.frame.size.height);
    self.bannerView.frame = newBannerFrame;

    // Fade ad banner in after rotation.
    [UIView animateWithDuration:0.15 animations:^{
        self.bannerView.alpha = 1;
    }];
    
    [self setCollectionViewPosition];
}

- (CGRect)getScreenFrameForCurrentOrientation
{
    return [self getScreenFrameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGRect)getScreenFrameForOrientation:(UIInterfaceOrientation)orientation
{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds;
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    //implicitly in Portrait orientation.
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    
    if (!statusBarHidden) {
        CGFloat statusBarHeight = 20; //Needs a better solution, FYI statusBarFrame reports wrong in some cases..
        fullScreenRect.size.height -= statusBarHeight;
    }
    
    return fullScreenRect;
}


#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    self.adsEnabled = !controller.adsRemoved;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }

    // Move ad banner offscreen if it isn't already offscreen.
    if (self.adsEnabled == NO) {
        if (self.isShowingAd == YES) {
            [self moveBannerOffscreenAnimated:YES];
        }
        
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setProducts:self.products];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HourCell";
    HourCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.contentView.backgroundColor = [UIColor colorWithRed:236/255.f green:237/255.f blue:238/255.f alpha:1.0];

    if (cell == nil) {
        cell = [[HourCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDate *date = self.hours[indexPath.row];

    NSDateFormatter* localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"HH"];
    cell.localHourLabel.text = [localDateFormatter stringFromDate:date];

    NSDateFormatter* utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setDateFormat:@"HH"];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    cell.utcHourLabel.text = [utcDateFormatter stringFromDate:date];

    [utcDateFormatter setDateFormat:@"EEE"];
    cell.utcDayLabel.text = [utcDateFormatter stringFromDate:date];

    [localDateFormatter setDateFormat:@"EEE"];
    cell.localDayLabel.text = [localDateFormatter stringFromDate:date];
    
    // Accessibility - Local Day of Week
    [localDateFormatter setDateFormat:@"EEEE"];
    NSString *localAccessibleDayOfWeek = [localDateFormatter stringFromDate:date];
    
    // Accessibility - UTC Day of Week
    [utcDateFormatter setDateFormat:@"EEEE"];
    NSString *utcAccessibleDayOfWeek = [utcDateFormatter stringFromDate:date];
    
    // Accessibility - Local Time Zone
    [localDateFormatter setDateFormat:@"zzzz"];
    NSString *localAccessibleTimeZone = [localDateFormatter stringFromDate:date];

    // Accessibility - Set the full cell label
    [cell setAccessibilityLabel:[NSString stringWithFormat:@"%@ %@ hundred hours %@ is %@ %@ hundred hours UTC", localAccessibleDayOfWeek, cell.localHourLabel.text, localAccessibleTimeZone, utcAccessibleDayOfWeek, cell.utcHourLabel.text]];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeader" owner:self options:nil] objectAtIndex:0];
    header.delegate = self;
    header.localTimeZoneLabel.text = self.localTimeZone;
    
    // Accessibility - Local time zone string. This duplicates code found in
    // cellForRowAtIndexPath. Need to abstract out into common method.
    NSDate *date = [NSDate date];
    NSDateFormatter* localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"zzzz"];
    NSString *localAccessibleTimeZone = [localDateFormatter stringFromDate:date];
    [header.localTimeZoneLabel setAccessibilityLabel:localAccessibleTimeZone];

    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark - SectionHeaderDelegate

- (void)infoButtonPressed
{
    [self performSegueWithIdentifier:@"showAlternate" sender:nil];
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"bannerViewDidLoadAd");
    [self moveBannerOnscreen];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"didFailToReceiveAdWithError");
    [self moveBannerOffscreenAnimated:YES];
}

- (void)moveBannerOnscreen
{
    // If we're already showing the ad then there's nothing to do.
    if (self.isShowingAd) {
        return;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect newBannerPadViewFrame = self.bannerView.frame;
        newBannerPadViewFrame.origin.y = self.view.bounds.size.height - newBannerPadViewFrame.size.height;

        CGRect newCollectionFrame = self.collectionView.frame;
        newCollectionFrame.origin.y = COLLECTION_VIEW_TOP;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.bannerView.frame = newBannerPadViewFrame;
            self.bannerView.alpha = 1;
            self.collectionView.frame = newCollectionFrame;
        }];
    }
    else {
        CGRect newBannerViewFrame = self.bannerView.frame;
        newBannerViewFrame.origin.y = self.view.frame.size.height - newBannerViewFrame.size.height;
        
        CGRect newTableFrame = self.tableView.frame;
        newTableFrame.size.height = self.view.frame.size.height - newBannerViewFrame.size.height;

        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.frame = newTableFrame;
            self.bannerView.frame = newBannerViewFrame;
            self.bannerView.alpha = 1;
        }];
    }
    
    self.isShowingAd = YES;
}

- (void)moveBannerOffscreenAnimated:(BOOL)animated
{
    // If the ad is already offscreen then there's nothing to do here.
    if (!self.isShowingAd) {
        return;
    }
    
    float duration = animated ? 0.25 : 0.0;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect newBannerPadViewFrame = self.bannerView.frame;
        newBannerPadViewFrame.origin.y = self.view.bounds.size.height;

        CGRect newCollectionFrame = self.collectionView.frame;
        newCollectionFrame.origin.y = COLLECTION_VIEW_TOP + (self.bannerView.frame.size.height / 2);

        [UIView animateWithDuration:duration animations:^{
            self.bannerView.frame = newBannerPadViewFrame;
            self.bannerView.alpha = 0;
            self.collectionView.frame = newCollectionFrame;
        }];
    }
    else {
        CGRect newTableFrame = self.tableView.frame;
        newTableFrame.size.height = self.view.frame.size.height;
        
        CGRect newBannerViewFrame = self.bannerView.frame;
        newBannerViewFrame.origin.y = self.view.frame.size.height;

        [UIView animateWithDuration:duration animations:^{
            self.tableView.frame = newTableFrame;
            self.bannerView.frame = newBannerViewFrame;
            self.bannerView.alpha = 0;
        }];
    }
    
    self.isShowingAd = NO;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 24;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionHourCell *cell = (CollectionHourCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectionHourCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:236/255.f green:237/255.f blue:238/255.f alpha:1.0];
    
    NSDate *date = self.hours[indexPath.row];
    
    NSDateFormatter* localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"HH"];
    cell.localHourLabel.text = [localDateFormatter stringFromDate:date];
    
    NSDateFormatter* utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setDateFormat:@"HH"];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    cell.utcHourLabel.text = [utcDateFormatter stringFromDate:date];
    
    [utcDateFormatter setDateFormat:@"EEE"];
    cell.utcDayLabel.text = [utcDateFormatter stringFromDate:date];
    
    [localDateFormatter setDateFormat:@"EEE"];
    cell.localDayLabel.text = [localDateFormatter stringFromDate:date];
    
    cell.localTimeZoneLabel.text = self.localTimeZone;
    
    // Accessibility - Local Day of Week
    [localDateFormatter setDateFormat:@"EEEE"];
    NSString *localAccessibleDayOfWeek = [localDateFormatter stringFromDate:date];
    
    // Accessibility - UTC Day of Week
    [utcDateFormatter setDateFormat:@"EEEE"];
    NSString *utcAccessibleDayOfWeek = [utcDateFormatter stringFromDate:date];
    
    // Accessibility - Local Time Zone
    [localDateFormatter setDateFormat:@"zzzz"];
    NSString *localAccessibleTimeZone = [localDateFormatter stringFromDate:date];
    
    // Accessibility - Set the full cell label
    [cell setAccessibilityLabel:[NSString stringWithFormat:@"%@ %@ hundred hours %@ is %@ %@ hundred hours UTC", localAccessibleDayOfWeek, cell.localHourLabel.text, localAccessibleTimeZone, utcAccessibleDayOfWeek, cell.utcHourLabel.text]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(224, 78);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return UIEdgeInsetsMake(51, 24, 51, 24);
    }
    else {
        return UIEdgeInsetsMake(24, 24, 24, 24);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 24;
}

#pragma mark - Other

- (NSMutableArray *)populateHours
{
    NSMutableArray *timeConversions = [@[] mutableCopy];

    for (int i = 0; i < 24; i++) {
        NSDate *date = [[NSDate date] dateByAddingTimeInterval:SECONDS_PER_HOUR * i];
        timeConversions[i] = date;
    }
    
    return timeConversions;
}

- (void)setCollectionViewPosition
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        int y = self.isShowingAd ? COLLECTION_VIEW_TOP : COLLECTION_VIEW_TOP + (self.bannerView.frame.size.height / 2);

        CGRect collectionViewFrame = self.collectionView.frame;
        collectionViewFrame.origin.y = y;
        
        [UIView animateWithDuration:0.15 animations:^{
            self.collectionView.frame = collectionViewFrame;
        }];
    }
}

- (void)setLocalTimeZoneString
{
    NSString *abbreviation = [[NSTimeZone localTimeZone] abbreviation];
    
    if ([abbreviation hasPrefix:@"GMT"]) {
        self.localTimeZone = [NSString stringWithFormat:@"%@", abbreviation];
    }
    else {
        int offset = [[NSTimeZone localTimeZone] secondsFromGMT] / SECONDS_PER_HOUR;
        self.localTimeZone = [NSString stringWithFormat:@"%@ %i", abbreviation, offset];
    }
}

- (void)styleTableView
{
    [self.tableView setSeparatorColor:[UIColor colorWithRed:190/255.f green:190/255.f blue:193/255.f alpha:1.0]];
}

- (void)createAdBannerIfNeeded
{
    self.adsEnabled = ![[MPLIAPGateway sharedGateway] isProductPurchased:self.products[0]];
    
    if (self.adsEnabled) {
        int adHeight = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 50 : 66;
        CGRect screenFrame = [self getScreenFrameForCurrentOrientation];
        
        self.bannerView = [[ADBannerView alloc] init];
        self.bannerView.frame = CGRectMake(0, screenFrame.size.height, screenFrame.size.width, adHeight);
        self.bannerView.delegate = self;
        self.isShowingAd = NO;
        [self.view addSubview:self.bannerView];
    }
}

- (void)fetchIAPProducts
{
    [[MPLIAPGateway sharedGateway] fetchProductsWithBlock:^(BOOL success, NSArray *products) {
        self.products = products;
        [self createAdBannerIfNeeded];
    }];
}

@end