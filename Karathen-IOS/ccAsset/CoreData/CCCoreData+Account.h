//
//  CCCoreData+Account.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData.h"

@class CCAccount;
@interface CCCoreData (Account)


/**
 清空数据

 @param completion 回调
 */
- (void)clearAccountDataCompletion:(saveCompletion)completion;

/**
 查询所有账户

 @return 账户数组
 */
- (NSArray <CCAccount *> *)requestAllAccounts;


/**
 保存账户

 @param accountID 账户ID
 @param sortID 排序的ID
 @param accountName 账户名
 @param walletType 钱包
 @param importType 导入方式
 @param coinType 单链导入
 @param passWordInfo 密码提示
 @param completion 回调
 @return CCAccount
 */
- (CCAccount *)saveAccountWithAccountId:(NSString *)accountID
                                 sortID:(NSInteger)sortID
                            accountName:(NSString *)accountName
                             walletType:(CCWalletType)walletType
                             importType:(CCImportType)importType
                               coinType:(CCCoinType)coinType
                           passWordInfo:(NSString *)passWordInfo
                             completion:(saveCompletion)completion;


/**
 删除账户

 @param accountID 账户ID
 @param completion 回调
 */
- (void)deleteAccountWithAccountId:(NSString *)accountID completion:(saveCompletion)completion;


@end
