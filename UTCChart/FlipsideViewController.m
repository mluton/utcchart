//
//  FlipsideViewController.m
//  UTCChart
//
//  Created by Michael Luton on 11/19/12.
//  Copyright (c) 2012 Sandmoose Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import <MessageUI/MessageUI.h>
#import "MPLIAPGateway.h"

@interface FlipsideViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) SKProduct* removeAdProduct;
@property (weak, nonatomic) IBOutlet UIButton *removeAdButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
- (IBAction)feedbackPressed;
- (IBAction)removeAdButtonPressed;
- (IBAction)restorePurchaseButtonPressed;

@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 320.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.removeAdProduct = self.products[0];
    [Flurry logEvent:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.adsRemoved = [[MPLIAPGateway sharedGateway] isProductPurchased:self.removeAdProduct];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProductPurchased:) name:IAPGatewayProductPurchased object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAdsRemoved:(BOOL *)adsRemoved
{
    _adsRemoved = adsRemoved;
    [self setRemoveAdButtonProperties];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)feedbackPressed
{
    if ([MFMailComposeViewController canSendMail]) {
        NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [mailViewController setToRecipients:@[@"sandmoose@gmail.com"]];
        [mailViewController setMessageBody:[NSString stringWithFormat:@"<br/><br/><hr size=1><strong>UTC Chart Information</strong><br/>App Version: %@<br/>iOS Version: %@<hr size=1>", appVersion, iosVersion] isHTML:YES];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Send Mail" message:@"No email accounts have been configured for this device. At least one email account is required to send feedback." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)removeAdButtonPressed
{
    if (!self.adsRemoved) {
        [[MPLIAPGateway sharedGateway] purchaseProduct:self.products[0]];
    }
}

- (IBAction)restorePurchaseButtonPressed
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)onProductPurchased:(NSNotification *)notification
{
    self.adsRemoved = YES;
}

- (void)setRemoveAdButtonProperties
{
    if (self.adsRemoved) {
        [self.removeAdButton setTitle:@"Thank you for your support!" forState:UIControlStateNormal];
        [self.removeAdButton setTitleColor:[UIColor colorWithRed:202.0f/255.0f green:202.0f/255.0f blue:204.0f/255.0f alpha:1] forState:UIControlStateNormal];
        self.removeAdButton.userInteractionEnabled = NO;
        self.restoreButton.alpha = 0;
        self.restoreButton.userInteractionEnabled = NO;
    }
    else {
        [self.removeAdButton setTitle:self.removeAdProduct.localizedTitle forState:UIControlStateNormal];
        [self.removeAdButton setTitleColor:[UIColor colorWithRed:102.0f/255.0f green:204.0f/255.0f blue:255.0f/255.0f alpha:1] forState:UIControlStateNormal];
        self.removeAdButton.userInteractionEnabled = YES;
        self.restoreButton.alpha = 1;
        self.restoreButton.userInteractionEnabled = YES;
    }
}

#pragma mark - MailComposeDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
