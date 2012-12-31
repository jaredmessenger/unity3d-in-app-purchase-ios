//
//  PurchaseBinding.m
//  Store
//
//  Created by Jared Messenger on 12/28/12.
//
//

#import "Store.h"

// Converts C style string to NSString
#define GetStringParam( _x_ ) ( _x_ != NULL ) ? [NSString stringWithUTF8String:_x_] : [NSString stringWithUTF8String:""]

void UnitySendMessage( const char * className, const char * methodName, const char * param );

void _initStoreWithProducts(const char *products)
{
    Store *store = [Store sharedSingleton];
    [store loadStoreWithProducts:GetStringParam(products)];
}

void _setVerificationServer(const char *url)
{
    Store *store = [Store sharedSingleton];
    [store setVerifyTransaction:YES];
    [store setVerifyServer:GetStringParam(url)];
}

bool _canMakeStorePurchases()
{
    Store *store = [Store sharedSingleton];
    return [store canMakeStorePurchases];
}

void _purchaseProduct(const char *productNameChar)
{
    NSString *productName = GetStringParam(productNameChar);
    Store *store = [Store sharedSingleton];
    [store purchaseItemByName:productName];
}

void _getProductInfo(const char *productNameChar)
{
    NSString *productName = GetStringParam(productNameChar);
    Store *store = [Store sharedSingleton];
    [store getItemInfo:productName];
}



