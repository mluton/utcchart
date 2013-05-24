//
//  IAPGateway.m
//  UTCChart
//
//  Created by Michael Luton on 5/15/13.
//  Copyright (c) 2013 Sandmoose Software. All rights reserved.
//

#import "IAPGateway.h"
#import "Lockbox.h"

NSString* const IAPGatewayProductPurchased = @"IAPGatewayProductPurchased";

@interface IAPGateway () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, copy) NSSet* productIds;
@property (nonatomic, copy) IAPGatewayProductsBlock callback;

@end

@implementation IAPGateway

- (id)initWithProductIds:(NSSet *)productIds
{
    self = [super init];
    
    if (self) {
        self.productIds = productIds;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

- (void)fetchProductsWithBlock:(IAPGatewayProductsBlock)block
{
    self.callback = block;
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIds];
    request.delegate = self;
    [request start];
}

- (BOOL)isProductPurchased:(SKProduct *)product
{
    NSString* value = [Lockbox stringForKey:product.productIdentifier];
    return [value isEqualToString:@"1"] ? YES : NO;
    
}

- (void)purchaseProduct:(SKProduct *)product
{
    SKPayment* payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark -

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
    self.callback(YES, response.products);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.callback(NO, nil);
}

#pragma mark - payment transaction observer

- (void)markProductPurchased:(NSString*)productIdentifier
{
    [Lockbox setString:@"1" forKey:productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPGatewayProductPurchased object:productIdentifier];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {

            case SKPaymentTransactionStatePurchased:
                [self markProductPurchased:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [[[UIAlertView alloc] initWithTitle:@"Purchase Failed" message:@"Unable to complete purchase. Please try again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            
            case SKPaymentTransactionStateRestored:
                [self markProductPurchased:transaction.originalTransaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

@end
