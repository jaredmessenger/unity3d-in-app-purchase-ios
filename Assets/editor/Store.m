//
//  Store.m
//  Store
//
//  Created by Jared Messenger on 12/28/12.
//
//

#import "Store.h"


@implementation Store
@synthesize products = _products;
static Store *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[Store alloc] init];
    }
}

+ (Store*) sharedSingleton
{
    return sharedSingleton;
}

- (void) loadStoreWithProducts:(NSString *) products
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSSet *items = [Store unityStringToSet:products];
    
    //NSSet *productIdentifiers = [NSSet setWithObjects:@"turbo", @"coins", nil];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:items];
    
    request.delegate = self;
    [request start];
    
}

- (bool) canMakeStorePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self setProducts:[response products] ];
    
    
    for(SKProduct *product in [self products])
    {
        NSLog(@"Product title: %@" , product.localizedTitle);
        NSLog(@"Product description: %@", product.localizedDescription);
        NSLog(@"Product price: %@", product.price);
        NSLog(@"Product id: %@", product.productIdentifier);
    }
    
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@", invalidProductId);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseNotification" object:self];
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    
}


//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                //[self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //[self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                //[self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

+ (NSSet*) unityStringToSet:(NSString*) productString
{
    
    NSArray *items = [productString componentsSeparatedByString:@","];
    NSSet *products = [NSSet setWithArray:items];
    return products;
}

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


@end

