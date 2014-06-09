//
//  KCoinRecharge.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-8-28.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ClientAgent.h"

#define PRODUCT_ID_COIN_300     @"cn.kbar.kcoin_300"
#define PRODUCT_ID_COIN_650     @"cn.kbar.kcoin_650"
#define PRODUCT_ID_COIN_1000    @"cn.kbar.kcoin_1000"
#define PRODUCT_ID_COIN_1500    @"cn.kbar.kcoin_1500"
#define PRODUCT_ID_MONTHLY_CARD @"cn.kbar.time_service.month"
#define PRODUCT_ID_WEEKLY_CARD  @"cn.kbar.time_service.week"

@interface KCoinRecharge : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    enum PRODUCT_TYPE
    {
        KCOIN_300,
        KCOIN_650,
        KCOIN_1000,
        KCOIN_1500,
        KMONTH_SERVIE,
        KWEEK_SERVICE
    };
    
    NSString    *mProductID;
    ClientAgent *mClientAgent;
    BOOL        mBusy;
}

@property (retain, nonatomic) NSString* mToken;
@property (retain, nonatomic) NSString* mUserID;

- (bool)CanMakePay;
- (void)RequestProductData;
- (BOOL)BuyProduct:(enum PRODUCT_TYPE)type UserID:(NSString*)userID Token:(NSString*)token;
- (BOOL)BuyProductWithProductID:(NSString*)productID UserID:(NSString *)userID Token:(NSString *)token;
@end
