//
//  CCTradeConfirmViewController.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/17.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCViewController.h"
@class CCErc721TokenInfoModel;

@interface CCTradeConfirmViewController : CCViewController

@property (nonatomic, copy) void(^backTxHash)(NSString *txId);


//dapp的转账
@property (nonatomic, assign) BOOL isDapp;
@property (nonatomic, strong) NSString *dappUrl;

//
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) NSString *toAddress;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, weak) CCWalletData *walletData;

//应用内转账
@property (nonatomic, weak) CCErc721TokenInfoModel *tokenModel;
@property (nonatomic, weak) CCAsset *asset;

//dapp转账
@property (nonatomic, strong) NSString *gasPrice;
@property (nonatomic, strong) NSString *gasLimit;
@property (nonatomic, strong) NSData *data;


@end
