//
//  CCDAppBrowserWKVC+JS.m
//  ccAsset
//
//  Created by SealWallet on 2018/10/17.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCDAppBrowserWKVC+JS.h"
#import "NSData+Extend.h"
#import "CCWalletData.h"
#import "CCTradeConfirmViewController.h"

@implementation CCDAppBrowserWKVC (JS)

#pragma mark - js调用oc
- (void)jsCallOc {
    @weakify(self)
    [self.jsBridge registerHandler:@"signTransaction" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self signTransaction:data callBack:responseCallback];
    }];
    
    
    [self.jsBridge registerHandler:@"signPersonalMessage" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self signPersonalMessage:data callBack:responseCallback];
    }];
    
    
//    [self.jsBridge registerHandler:@"showHint" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSString *dataS = [NSString stringWithFormat:@"%@",data];
////        [MBProgressHUD showMessage:dataS];
//    }];
}

#pragma mark - oc调用js
- (void)ocCallJs {
    [self setDefaultAccountFinish:nil];
}

- (void)setDefaultAccountFinish:(void(^)(void))finish {
    CCWalletData *walletData = self.walletData;
    NSDictionary *userInfo = @{@"account":walletData.address};
    [self.jsBridge callHandler:@"setDefaultAccount" data:userInfo.mj_JSONObject responseCallback:^(id responseData) {
        if (finish) {
            finish();
        }
        DLog(@"%@",responseData);
    }];
}

- (void)callAfterReload {
    CCWalletData *walletData = self.walletData;
    NSDictionary *userInfo = @{@"account":walletData.address};
    [self.jsBridge callHandler:@"callAfterReload" data:userInfo.mj_JSONObject responseCallback:^(id responseData) {
        DLog(@"%@",responseData);
    }];
}

#pragma mark - 签署信息
- (void)signPersonalMessage:(id)data callBack:(WVJBResponseCallback)responseCallback {
    NSString *params = data[@"params"][0];
    NSData *messageData = [NSData convertHexStrToData:[params substringFromIndex:2]];
    NSString *message = messageData.mj_JSONString;
    @weakify(self)
    [self messageAlertTitle:@"确认签署本信息：" message:message cancel:@"取消" sureTitle:@"确定" destructive:NO alertAction:^(NSInteger index) {
        @strongify(self)
        if (index == 0) {
            responseCallback(nil);
        } else {
            [self showPassWord:messageData callBack:responseCallback];
        }
    }];
}

- (void)showPassWord:(NSData *)messageData callBack:(WVJBResponseCallback)responseCallback {
    @weakify(self)
    [self showPassWordMaxLength:0 onlyNum:NO completion:^(NSString *text) {
        @strongify(self)
        [self signPersonalMessage:messageData passWord:text callBack:responseCallback];
    }];
}

- (void)signPersonalMessage:(NSData *)messageData passWord:(NSString *)passWord callBack:(WVJBResponseCallback)responseCallback {
    [CCAlertView showLoadingMessage:Localized(@"Signing...")];
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.walletData.wallet.accountID password:passWord completion:^(NSString *walletInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            if (!walletInfo) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletErrorPWD]];
                responseCallback(nil);
                return;
            }
            @strongify(self)
            
            Account *account;
            if (self.walletData.importType == CCImportTypeMnemonic || self.walletData.importType == CCImportTypeSeed) {
                account = [[Account alloc] initWithMnemonicPhrase:walletInfo coinType:60 account:0 external:0 slot:self.walletData.wallet.slot];
            } else {
                account = [Account accountWithPrivateKey:[SecureData hexStringToData:[walletInfo hasPrefix:@"0x"]?walletInfo:[@"0x" stringByAppendingString:walletInfo]]];
            }
            
            Signature *signature = [account signMessage:messageData];
            SecureData *rData = [SecureData secureDataWithData:signature.r];
            SecureData *sData = [SecureData secureDataWithData:signature.s];
            [rData append:sData];
            [rData appendByte:signature.v+27];
            
            responseCallback(rData.hexString);
            
        });
    }];
}


#pragma mark - 签名转账
- (void)signTransaction:(id)data callBack:(WVJBResponseCallback)responseCallback {
    NSLog(@"data -  %@",data);
    NSDictionary *dic = data[@"params"][0];
    
    NSString *transStr = dic[@"data"];
    NSData *transData = [NSData convertHexStrToData:[transStr substringFromIndex:2]];
    NSString *toAddress = dic[@"to"];
    NSString *gas = dic[@"gas"];
    if (gas) {
        gas = [BigNumber bigNumberWithHexString:gas].decimalString;
    }
    NSString *gasPrice = dic[@"gasPrice"];
    if (gasPrice) {
        gasPrice = [BigNumber bigNumberWithHexString:gasPrice].decimalString;
    }
    NSString *value = dic[@"value"];
    if (value) {
        value = [BigNumber bigNumberWithHexString:data[@"params"][0][@"value"]].decimalString;
    } else {
        value = @"0";
    }
    
    CCTradeConfirmViewController *confirmVC = [[CCTradeConfirmViewController alloc] init];
    confirmVC.isDapp = YES;
    confirmVC.dappUrl = self.webView.URL.absoluteString;
    confirmVC.toAddress = toAddress;
    confirmVC.value = value;
    confirmVC.walletData = self.walletData;
    confirmVC.gasPrice = gasPrice;
    confirmVC.gasLimit = gas;
    confirmVC.data = transData;
    confirmVC.backTxHash = ^(NSString *txId) {
        responseCallback(txId);
    };
    [self.rt_navigationController pushViewController:confirmVC animated:YES complete:nil];
}

@end
