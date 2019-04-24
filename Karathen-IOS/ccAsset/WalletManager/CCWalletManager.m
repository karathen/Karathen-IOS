//
//  CCWalletManager.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/30.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletManager.h"
#import "MnemonicCode.h"

static CCWalletManager *walletManager = nil;

@implementation CCWalletManager

+ (CCWalletManager *)walletManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        walletManager = [[CCWalletManager alloc] init];
    });
    return walletManager;
}

#pragma mark - 随机生成助记词
+ (NSString *)randomMnemonic {
    NSMutableData *randomData = [NSMutableData dataWithLength:16];
    int result = SecRandomCopyBytes(kSecRandomDefault, randomData.length, randomData.mutableBytes);
    if (result != noErr) {
        return nil;
    }
    MnemonicCode *mnemonicCode = [MnemonicCode shareInstance];
    NSString *mnemonicText = [mnemonicCode toMnemonic:randomData];
    if (![mnemonicCode check:mnemonicText]) {
        return nil;
    }
    return mnemonicText;
}

#pragma mark - 错误描述
+ (NSString *)messageWithError:(CCWalletError)error {
    NSString *errorString = Localized(@"Unknown error");
    switch (error) {
        case CCWalletErrorMnemonicsCount:
        case CCWalletErrorMnemonicsValidWord:
        case CCWalletErrorMnemonicsValidPhrase:
            errorString = Localized(@"Your mnemonic words incorrect");
            break;
        case CCWalletErrorKeyStoreLength:
            errorString = Localized(@"Keystore invalid");
            break;
        case CCWalletErrorKeyStoreValid:
            errorString = Localized(@"Decryption of Keystore failed");
            break;
        case CCWalletErrorPrivateKeyLength:
            errorString = Localized(@"Private key length is not long enough");
            break;
        case CCWalletErrorAddressRepeat:
            errorString = Localized(@"Wallet already exists");
            break;
        case CCWalletErrorNotGasPrice:
            errorString = Localized(@"Gas price retrieval failed");
            break;
        case CCWalletErrorPWD:
            errorString = Localized(@"Password incorrect");
            break;
        case CCWalletChangePasswordSuc:
            errorString = Localized(@"Reset password succeeds");
            break;
        case CCWalletErrorSend:
            errorString = Localized(@"Send raw transaction failed");
            break;
        case CCWalletSucSend:
            errorString = Localized(@"Send raw transaction succeeded");
            break;
        case CCWalletImportPrivateKeyValidPhrase:
            errorString = Localized(@"Private Key incorrect");
            break;
        case CCWalletImportWIFValidPhrase:
            errorString = Localized(@"WIF incorrect");
            break;
        case CCWalletClaimGasFail:
            errorString = Localized(@"Send raw transaction failed");
            break;
        case CCWalletClaimGasSuccess:
            errorString = Localized(@"Claim Succeeded");
            break;
        case CCWalletErrorNSOrderedDescending:
            errorString = Localized(@"Exceed your balance");
            break;
        case CCWalletAddressWrong:
            errorString = Localized(@"Address incorrect");
            break;
        case CCWalletTradeSucReamrkFail:
            errorString = Localized(@"Send raw transaction succeeded but remark failed");
            break;
        case CCWalletErrorGetBalance:
            errorString = Localized(@"获取余额失败");
            break;
        default:
            break;
    }
    return errorString;
}


#pragma mark - 是否是测试
+ (BOOL)isTest {
    return NO;
}


@end
