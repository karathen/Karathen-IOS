//
//  CCQRCodeRule.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/30.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CCQRCodeRuleType) {
    CCQRCodeRuleTypeNone,//没有规则，直接输出
    CCQRCodeRuleTypeReceive,//收款二维码
};

@class LBXScanResult;
@interface CCQRCodeRule : NSObject

/**
 生成收款码

 @param walletData 钱包
 @param asset 资产
 @return 字符串
 */
+ (NSString *)receiveQRCodeWithWallet:(CCWalletData *)walletData
                                asset:(CCAsset *)asset;



/**
 处理扫描结果

 @param array 扫描结果
 @param currentWallet 钱包
 @param currentAsset 当前资产可为空
 @param completion 回调（提示信息，扫描的信息，解析的地址，解析的资产）
 */
+ (void)scanReceiveQRCode:(NSArray<LBXScanResult*>*)array
            currentWallet:(CCWalletData *)currentWallet
             currentAsset:(CCAsset *)currentAsset
               completion:(void(^)(NSString *message,NSString *scanResult,NSString *toAddress,CCAsset *asset))completion;


/**
 没有规则
 
 @param array 扫描结果
 @param completion 回调
 */
+ (void)scanNoneTypeCode:(NSArray<LBXScanResult*>*)array
              completion:(void(^)(BOOL suc,NSString *message))completion;

@end
