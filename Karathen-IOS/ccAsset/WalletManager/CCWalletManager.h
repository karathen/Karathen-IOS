//
//  CCWalletManager.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/30.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ethers/ethers.h>

typedef NS_ENUM(NSInteger, CCWalletError) {
    CCWalletErrorSuccess = 0,       //成功
    CCWalletErrorMnemonicsCount = 1,        //助记词 个数不够
    CCWalletErrorMnemonicsValidWord = 2,    //某个 助记词有误（助记词有误）
    CCWalletErrorMnemonicsValidPhrase = 3,  //助记词 有误
    CCWalletErrorKeyStoreLength = 5,        //KeyStore长度不够
    CCWalletErrorKeyStoreValid = 6,         //KeyStore解密失败
    CCWalletErrorPrivateKeyLength = 7,      //私钥长度不够
    CCWalletErrorAddressRepeat = 30,        //钱包导入重复
    
    CCWalletCreateSuc = 8,                  //钱包创建成功
    CCWalletImportMnemonicsSuc = 9,         //助记词导入成功
    CCWalletImportKeyStoreSuc = 10,         //KeyStore导入成功
    CCWalletImportPrivateKeySuc = 11,       //私钥导入成功
    CCWalletImportWIFSuc = 27,              //WIF导入成功

    CCWalletImportPrivateKeyValidPhrase = 22,       //私钥有误
    CCWalletImportWIFValidPhrase = 29,       //WIF有误

    CCWalletErrorNotGasPrice = 12,//获取GasPrice失败
    CCWalletErrorNSOrderedDescending = 14, //余额不足
    
    CCWalletErrorPWD = 15, //密码错误
    CCWalletErrorSend = 16, //转账失败
    CCWalletSucSend = 17, //转账成功
    CCWalletErrorGetBalance = 40,//获取余额失败
    CCWalletGetBalanceSuc = 41,//获取余额成功
    
    CCWalletDeleteAccountSuc = 19,        //删除账户成功
    CCWalletChangePasswordSuc = 20,        //修改密码成功
    CCWalletExportPrivateKeySuc = 21,        //导出私钥成功
    CCWalletExportMnemonicSuc = 23,        //导出助记词成功
    CCWalletExportWIFSuc = 28,        //导出WIF成功
    CCWalletExportKeystoreSuc = 32,        //导出Keystore成功

    CCWalletClaimGasFail = 24,//提取GAS失败
    CCWalletClaimGasSuccess = 25,//提取GAS成功
    
    CCWalletAddressWrong = 26,//地址错误
    CCWalletTradeSucReamrkFail = 31,       //广播成功，备注失败
};

@interface CCWalletManager : NSObject




/**
 walletManager

 @return walletManager
 */
+ (CCWalletManager *)walletManager;


/**
 随机生成助记词

 @return 助记词
 */
+ (NSString *)randomMnemonic;

/**
 错误描述
 
 @param error 错误
 @return 描述
 */
+ (NSString *)messageWithError:(CCWalletError)error;

/**
 是否是测试

 @return 是否是测试 YES测试 NO正式
 */
+ (BOOL)isTest;

@end
