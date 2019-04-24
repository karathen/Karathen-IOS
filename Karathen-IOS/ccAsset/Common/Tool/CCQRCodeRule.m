//
//  CCQRCodeRule.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/30.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCQRCodeRule.h"
#import "LBXScanTypes.h"

@implementation CCQRCodeRule

#pragma mark - 生成收款码
+ (NSString *)receiveQRCodeWithWallet:(CCWalletData *)walletData
                          asset:(CCAsset *)asset {
    if (asset) {
        NSString *codeCoinType;
        CCCoinType coinType = walletData.type;
        switch (coinType) {
            case CCCoinTypeETH:
            {
                codeCoinType = @"ethereum";
            }
                break;
            case CCCoinTypeNEO:
            {
                codeCoinType = @"neo";
            }
                break;
            case CCCoinTypeONT:
            {
                codeCoinType = @"ontology";
            }
                break;
            default:
                break;
        }
        return [NSString stringWithFormat:@"%@:%@?contractAddress=%@",codeCoinType,walletData.address,asset.tokenAddress];
    } else {
        return walletData.address;
    }

}


#pragma mark - 扫描收款码
+ (void)scanReceiveQRCode:(NSArray<LBXScanResult*>*)array
            currentWallet:(CCWalletData *)currentWallet
             currentAsset:(CCAsset *)currentAsset
               completion:(void(^)(NSString *message,NSString *scanResult,NSString *toAddress,CCAsset *asset))completion {
    if (array.count == 0) {
        completion(Localized(@"Unidentifiable QR code"),nil,nil,nil);
        return;
    }
    LBXScanResult *scanResult = array.firstObject;
    NSString *scanStr = scanResult.strScanned;
    
    //有
    if (scanStr && scanStr.length) {
        //包含问号
        if ([scanStr rangeOfString:@"?"].length == 1) {
            //替换& 和 ：，得到处理好的字典
            scanStr = [scanStr stringByReplacingOccurrencesOfString:@"?" withString:@"&"];
            scanStr = [scanStr stringByReplacingOccurrencesOfString:@":" withString:@"="];
            NSArray *scanArray = [scanStr componentsSeparatedByString:@"&"];
            NSMutableDictionary *scanDic = [NSMutableDictionary dictionary];
            for (NSString *obj in scanArray) {
                NSArray *objArr = [obj componentsSeparatedByString:@"="];
                if (objArr.count > 1) {
                    [scanDic setValue:objArr[1] forKey:objArr[0]];
                }
            }
            //属于哪条链
            CCCoinType coinType = CCCoinTypeNone;
            //转账地址
            NSString *toAddress;
            if ([scanDic.allKeys containsObject:@"ethereum"]) {
                coinType = CCCoinTypeETH;
                toAddress = scanDic[@"ethereum"];
            } else if ([scanDic.allKeys containsObject:@"neo"]) {
                coinType = CCCoinTypeNEO;
                toAddress = scanDic[@"neo"];
            } else if ([scanDic.allKeys containsObject:@"ontology"]) {
                coinType = CCCoinTypeONT;
                toAddress = scanDic[@"ontology"];
            } else {
                completion(nil,scanStr,nil,nil);
                return;
            }
            //比对当前扫描的链和钱包的链
            if (currentWallet.type != coinType) {
                completion(Localized(@"Different chain cannot make transaction"),scanStr,nil,nil);
                return;
            }
            //合约地址
            NSString *assetAddress;
            if ([scanDic.allKeys containsObject:@"contractAddress"]) {
                assetAddress = scanDic[@"contractAddress"];
            }
            
            //查找需要转账的资产
            CCAsset *asset = [currentWallet assetWithToken:assetAddress];
            if (!asset) {
                completion(Localized(@"This type of asset is not exists in your wallet"),scanStr,toAddress,nil);
                return;
            }
            
            //比对当前资产是否一致
            if (currentAsset) {
                if ([currentAsset.tokenAddress compareWithString:asset.tokenAddress]) {
                    completion(nil,scanStr,toAddress,asset);
                } else {                    
                    completion(Localized(@"Receipt asset does not match with transferred asset,please check again"),scanStr,toAddress,asset);
                }
            } else {
                completion(nil,scanStr,toAddress,asset);
            }
        } else {
            //是否满足对应链地址的规则
            if ([CCWalletData checkAddress:scanStr coinType:currentWallet.wallet.coinType]) {
                completion(nil,scanStr,scanStr,nil);
            } else {
                completion(nil,scanStr,nil,nil);
            }
        }
    } else {
        completion(nil,scanStr,nil,nil);
    }
}


#pragma mark - 没有规则
+ (void)scanNoneTypeCode:(NSArray<LBXScanResult*>*)array
              completion:(void(^)(BOOL suc,NSString *message))completion {
    if (array.count == 0) {
        completion(NO,Localized(@"Unidentifiable QR code"));
        return;
    }
    LBXScanResult *scanResult = array.firstObject;
    NSString *scanStr = scanResult.strScanned;
    if (completion) {
        completion(YES,scanStr);
    }
}

@end
