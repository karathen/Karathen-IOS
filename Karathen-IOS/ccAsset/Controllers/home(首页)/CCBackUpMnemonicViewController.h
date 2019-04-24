//
//  CCBackUpMnemonicViewController.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/13.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCScrollViewController.h"

typedef NS_ENUM(NSInteger, CCBackUpMnemonicVCType) {
    CCBackUpMnemonicVCCreate = 0,//助记词创建
    CCBackUpMnemonicVCExport,//助记词导出
    CCBackUpMnemonicVCBackUp,//助记词备份
};


@interface CCBackUpMnemonicViewController : CCScrollViewController

@property (nonatomic, assign) CCBackUpMnemonicVCType type;

//
@property (nonatomic, assign) CCWalletType walletType;

//助记词创建
@property (nonatomic, strong) NSString *walletName;
@property (nonatomic, strong) NSString *pinWord;
@property (nonatomic, strong) NSString *pwdInfo;

//助记词导出
@property (nonatomic, strong) NSString *mnemonic;

//助记词备份
@property (nonatomic, weak) CCAccountData *accountData;

@end
