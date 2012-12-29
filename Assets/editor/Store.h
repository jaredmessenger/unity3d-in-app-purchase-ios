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
@property(nonatomic, retain)NSArray *products;
+ (Store *) sharedSingleton;
- (void) loadStoreWithProducts:(NSString *) products;
- (bool) canMakeStorePurchases;
+ (NSSet *) unityStringToSet:(NSString *) unityString;
+ (NSString *)base64forData:(NSData *)theData;

@end
