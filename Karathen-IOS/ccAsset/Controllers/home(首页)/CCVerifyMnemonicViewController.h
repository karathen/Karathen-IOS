//
//  CCVerifyMnemonicViewController.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCScrollViewController.h"

@interface CCVerifyMnemonicViewController : CCScrollViewController

@property (nonatomic, assign) CCWalletType walletType;

//是否是创建还是备份助记词
@property (nonatomic, assign) BOOL isImport;

@property (nonatomic, strong) NSString *mnemonic;
@property (nonatomic, strong) NSString *pinWord;

@property (nonatomic, strong) NSString *walletName;
@property (nonatomic, strong) NSString *pwdInfo;

//备份
@property (nonatomic, weak) CCAccountData *accountData;

@end
