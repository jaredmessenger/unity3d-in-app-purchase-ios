//
//  Store.h
//  Store
//
//  Created by Jared Messenger on 12/28/12.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface Store : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSMutableDictionary *productsDict;
}
@property(nonatomic, retain) NSArray *products;
@property(nonatomic, retain) NSString *verifyServer;
@property(nonatomic, assign) BOOL verifyTransaction;

+ (Store *) sharedSingleton;
- (void) loadStoreWithProducts:(NSString *) products;
- (bool) canMakeStorePurchases;
- (void) getItemInfo:(NSString *) itemName;
- (void) purchaseItemByName:(NSString *) itemName;
- (void) purchaseItem:(SKProduct *) item;
- (void) completeTransaction:(SKPaymentTransaction *) transaction;
- (void) restoreTransaction:(SKPaymentTransaction *) transaction;
- (void) failedTransaction:(SKPaymentTransaction *) transaction;
- (void) finishTransactionSuccessfully:(NSNotification *)notification;
- (void) finishTransactionFailure:(NSNotification *)notification;
- (void) verifyReceipt:(NSString *) receipt;
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
+ (NSSet *) unityStringToSet:(NSString *) unityString;
+ (NSString *)base64forData:(NSData *)theData;

@end
