//
//  KCoinRecharge.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-8-28.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "KCoinRecharge.h"
#import "ClientAgent.h"
#import "CustomAlertView.h"

@implementation KCoinRecharge

-(id)init
{
    if ((self = [super init])) {
        //----监听购买结果
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        mProductID = nil;
        mClientAgent = nil;
        mBusy = NO;
    }
    return self;
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    [mProductID release];
    [mClientAgent release];
    [super dealloc];
}

- (bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

- (void)RequestProductData
{
    NSArray *product = [[NSArray alloc] initWithObjects:@"cn.kbar.kcoin_test_1000",nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    [product release];
}

- (BOOL)BuyProductWithProductID:(NSString*)productID UserID:(NSString *)userID Token:(NSString *)token
{
    if(mBusy)
    {
        return NO;
    }
    
    [mProductID release];
    mProductID = productID;
    
    if(mProductID != nil)
    {
        _mToken = token;
        _mUserID = userID;
        NSArray *product = [[NSArray alloc] initWithObjects:mProductID, nil];
        NSSet *nsset = [NSSet setWithArray:product];
        SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
        request.delegate=self;
        [request start];
        [product release];
        
        //SKPayment *payment = [SKPayment paymentWithProductIdentifier:mProductID];
        //NSLog(@"---------发送购买请求------------");
        //[[SKPaymentQueue defaultQueue] addPayment:payment];
        mBusy = YES;
    }
    return YES;
}

- (BOOL)BuyProduct:(enum PRODUCT_TYPE)type UserID:(NSString*)userID Token:(NSString*)token
{
    if(mBusy)
    {
        return NO;
    }
    
    NSString    *productID;
    switch(type)
    {
        case KCOIN_1000:
            productID = PRODUCT_ID_COIN_1000;
            break;
        case KCOIN_1500:
            productID = PRODUCT_ID_COIN_1500;
            break;
        case KCOIN_300:
            productID = PRODUCT_ID_COIN_300;
            break;
        case KCOIN_650:
            productID = PRODUCT_ID_COIN_650;
            break;
        case KMONTH_SERVIE:
            //mProductID = [[NSString alloc] initWithString:@"cn.kbar.kgoldcoin_30"];
            productID = PRODUCT_ID_MONTHLY_CARD;
            break;
        case KWEEK_SERVICE:
            productID = PRODUCT_ID_WEEKLY_CARD;
            break;
    }
    return [self BuyProductWithProductID:productID UserID:userID Token:token];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *productList = response.products;
    SKProduct *myProduct = nil;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", [productList count]);
    // populate UI
    for(SKProduct *product in productList){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        if([product.productIdentifier isEqualToString:mProductID])
        {
            myProduct = product;
        }
    }
    
    //SKPayment *payment = [SKPayment paymentWithProductIdentifier:mProductID];
    SKPayment *payment = [SKPayment paymentWithProduct:myProduct];
    NSLog(@"---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [request autorelease];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                CustomAlertView *alerView =  [[CustomAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"您的交易请求已提交!"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                
                [alerView show];
                [alerView release];
                mBusy = NO;
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                CustomAlertView *alerView2 =  [[CustomAlertView alloc] initWithTitle:@"提示"
                                                                     message:@"购买失败，请重新尝试购买。"
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                
                [alerView2 show];
                [alerView2 release];
                mBusy = NO;
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                mBusy = NO;
                NSLog(@"-----已经购买过该商品 --------");
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction

{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        NSString *receipt = [[NSString alloc] initWithData:transaction.transactionReceipt
                                                 encoding:NSUTF8StringEncoding];
        NSLog(@"Receipt:%@", receipt);
        
        NSString* jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes
                                           length:transaction.transactionReceipt.length];
        NSLog(@"Encoded Receipt:%@", jsonObjectString);
        
        if(mClientAgent == nil)
            mClientAgent = [[ClientAgent alloc]init];
        [mClientAgent verifyReceipt:jsonObjectString UserID:_mUserID Token:_mToken];
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            NSLog(@"Product ID:%@", bookid);
        }
    }
    
    // Remove the transaction from the payment queue.
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@" 交易恢复处理");
    
}

/**
 * 对Receipt进行Base64编码
 */
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}
@end
