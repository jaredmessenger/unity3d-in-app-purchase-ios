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
    [sharedSingleton setProducts:[response products]];
    
    productsDict = [[NSMutableDictionary alloc] init];
    for(SKProduct *product in [sharedSingleton products])
    {
        // Add to a dictionary to easily get it by it's id
        [productsDict setObject:product forKey:product.productIdentifier];
        
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

- (void) purchaseItemByName:(NSString *) itemName
{
    SKProduct *product = [productsDict objectForKey:itemName];
    if(product)
    {
        [sharedSingleton purchaseItem:product];
    }else{
        NSLog(@"Product %@ does NOT exist", itemName);
    }
}

- (void) purchaseItem:(SKProduct *) item
{
    NSLog(@"Purchasing item %@", item.localizedTitle);
    SKPayment *payment = [SKPayment paymentWithProduct:item];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
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
                NSLog(@"Purchased Successful");
                break;
            case SKPaymentTransactionStateFailed:
                //[self failedTransaction:transaction];
                NSLog(@"Purcahse Failed");
                break;
            case SKPaymentTransactionStateRestored:
                //[self restoreTransaction:transaction];
                NSLog(@"Purchase Restored");
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

