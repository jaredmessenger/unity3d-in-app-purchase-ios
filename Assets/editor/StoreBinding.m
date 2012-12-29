//
//  PurchaseBinding.m
//  Store
//
//  Created by Jared Messenger on 12/28/12.
//
//

#import "Store.h"

// Converts NSString to C style string by way of copy (Mono will free it)
#define MakeStringCopy( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL

// Converts C style string to NSString
#define GetStringParam( _x_ ) ( _x_ != NULL ) ? [NSString stringWithUTF8String:_x_] : [NSString stringWithUTF8String:""]

void _initStoreWithProducts(const char * products)
{
    Store *purchase = [Store sharedSingleton];
    [purchase loadStoreWithProducts:GetStringParam(products)];
}

bool _canMakeStorePurchases()
{
    Store *store = [Store sharedSingleton];
    return [store canMakeStorePurchases];
}

void _purchaseItem(const char *item)
{
    
}

