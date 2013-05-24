//
//  IAPGateway.h
//  UTCChart
//
//  Created by Michael Luton on 5/15/13.
//  Copyright (c) 2013 Sandmoose Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NSString *const IAPGatewayProductPurchased;

typedef void (^IAPGatewayProductsBlock)(BOOL success, NSArray *products);

@interface IAPGateway : NSObject

- (id)initWithProductIds:(NSSet*)productIds;
- (void)fetchProductsWithBlock:(IAPGatewayProductsBlock)block;
- (BOOL)isProductPurchased:(SKProduct*)product;
- (void)purchaseProduct:(SKProduct*)product;

@end
