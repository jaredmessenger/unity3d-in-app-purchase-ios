//
//  Store.m
//  Store
//
//  Created by Jared Messenger on 12/28/12.
//
//

#import "Store.h"

// Converts NSString to C style string by way of copy (Mono will free it)
#define MakeStringCopy( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL

static NSString *const verifyPurchaseNotification = @"verifyPurchaseNotification";
static NSString *const verifyFailedNotification   = @"verifiedFailedNotification";

@implementation Store

@synthesize products            = _products;
@synthesize verifyTransaction   = _verifyTransaction;
@synthesize verifyServer        = _verifyServer;
 
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
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@", invalidProductId);
    }
    
    UnitySendMessage("StoreManager", "CallbackStoreLoadedSuccessfully", "");
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    UnitySendMessage("StoreManager", "CallbackStoreLoadFailed", "");
    
}

- (void) getItemInfo:(NSString *) itemName
{
    SKProduct *product = [productsDict objectForKey:itemName];
    if (product)
    {
        NSString *productInfoToString = [[NSString alloc]
                                         initWithFormat:@"%@|%@|%@|%@",
                                            product.localizedTitle,
                                            product.localizedDescription,
                                            product.price,
                                            product.productIdentifier];
        
        UnitySendMessage("StoreManager", "CallbackReceiveProductInfo", MakeStringCopy(productInfoToString));
        [productInfoToString release];
    }
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
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [sharedSingleton completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [sharedSingleton failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [sharedSingleton restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction:(SKPaymentTransaction *) transaction
{
    if([sharedSingleton verifyTransaction])
    {
        NSString *receipt = [Store base64forData:transaction.transactionReceipt];
        [[NSNotificationCenter defaultCenter] addObserver:sharedSingleton selector:@selector(finishTransactionSuccessfully:) name:verifyPurchaseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedSingleton selector:@selector(finishTransactionFailure:) name:verifyFailedNotification object:nil];
        [sharedSingleton verifyReceipt:receipt];
    }else{
        UnitySendMessage("StoreManager", "CallbackProvideContent", MakeStringCopy(transaction.originalTransaction.payment.productIdentifier));
    }
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) restoreTransaction:(SKPaymentTransaction *) transaction
{
    if([sharedSingleton verifyTransaction])
    {
        [[NSNotificationCenter defaultCenter] addObserver:sharedSingleton selector:@selector(finishTransactionSuccessfully:) name:verifyPurchaseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedSingleton selector:@selector(finishTransactionFailure:) name:verifyFailedNotification object:nil];
        NSString *receipt = [Store base64forData:transaction.originalTransaction.transactionReceipt];
        [sharedSingleton verifyReceipt:receipt];
    }else{
        UnitySendMessage("StoreManager", "CallbackProvideContent", MakeStringCopy(transaction.originalTransaction.payment.productIdentifier));
    }
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction failed");
        // error!
        UnitySendMessage("StoreManager", "CallbackTransactionFailed", "");
        // remove the transaction from the payment queue.
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    else
    {
        NSLog(@"User canceled Transaction");
        // User quit the transaction
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void) finishTransactionSuccessfully:(NSNotification *)notification
{
    if([notification object] != nil)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[notification object];
        NSLog(@"%i", [httpResponse statusCode]);
        UnitySendMessage("StoreManager", "CallbackProvideContent", "Product Awesome");
    }else{
        UnitySendMessage("StoreManager", "CallbackProvideContent", "Product Server Failed");
    }
    
    // Remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:sharedSingleton name:verifyPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedSingleton name:verifyFailedNotification object:nil];
}

- (void) finishTransactionFailure:(NSNotification *)notification
{
    UnitySendMessage("StoreManager", "CallbackTransactionFailed", "");
    [[NSNotificationCenter defaultCenter] removeObserver:sharedSingleton name:verifyPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedSingleton name:verifyFailedNotification object:nil];
}

//
// Send the receipt to the server to verify it was legit
//
- (void) verifyReceipt:(NSString *) receipt
{
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         receipt, @"receipt-data",
                         nil];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    NSURL *verifyPurchaseURL = [[NSURL alloc] initWithString:[sharedSingleton verifyServer]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:verifyPurchaseURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    [NSURLConnection connectionWithRequest:request delegate:sharedSingleton];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    [[NSNotificationCenter defaultCenter] postNotificationName:verifyPurchaseNotification object:httpResponse];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error.description);
    // If the server is down, just consider it verified
    [[NSNotificationCenter defaultCenter] postNotificationName:verifyPurchaseNotification object:nil];
}

+ (NSSet*) unityStringToSet:(NSString*) productString
{
    NSArray *items = [productString componentsSeparatedByString:@"|"];
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

