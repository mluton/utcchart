//
//  MPLIAPGateway.m
//  UTCChart
//
//  Created by Michael Luton on 5/16/13.
//  Copyright (c) 2013 Sandmoose Software. All rights reserved.
//

#import "MPLIAPGateway.h"

@implementation MPLIAPGateway

+ (id)sharedGateway
{
    static MPLIAPGateway* __instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet* products = [NSSet setWithObject:@"com.sandmoose.utcchart.RemoveAds"];
        __instance = [[MPLIAPGateway alloc] initWithProductIds:products];
    });
    
    return __instance;
}

@end
