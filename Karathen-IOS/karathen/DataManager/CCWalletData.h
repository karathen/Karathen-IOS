//
//  CCWalletData.h
//  Karathen
//
//  Created by Karathen on 2018/7/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAsset+CoreDataClass.h"
#import "CCWallet+CoreDataClass.h"
#import "CCWalletManager.h"

@class CCTokenInfoModel;

@interface CCWalletData : NSObject

//钱包
@property (nonatomic, strong, readonly) CCWallet *wallet;
//钱包地址
@property (nonatomic, strong, readonly) NSString *address;
//钱包名称
@property (nonatomic, strong, readonly) NSString *walletName;
//钱包的类型
@property (nonatomic, assign, readonly) CCCoinType type;
@property (nonatomic, assign, readonly) CCImportType importType;
//余额
@property (nonatomic, strong, readonly) NSString *balance;
//isSelected
@property (nonatomic, assign, readonly) BOOL isSelected;

//已开启的资产列表
@property (nonatomic, strong) NSMutableArray <CCAsset *> *assets;


/**
 创建钱包data

 @param wallet 钱包
 @return 钱包data
 */
+ (CCWalletData *)walletDataWithWallet:(CCWallet *)wallet;



/**
 导出私钥
 
 @param passWord password
 @param completion 回调
 */
- (void)exportPrivateKey:(NSString *)passWord
              completion:(void(^)(BOOL suc,NSString *privateKey,CCWalletError error))completion;

/**
 导出WIF
 
 @param passWord password
 @param completion 回调
 */
- (void)exportWIF:(NSString *)passWord
       completion:(void(^)(BOOL suc,NSString *wif,CCWalletError error))completion;


/**
 导出keystore

 @param passWord 密码
 @param completion 回调
 */
- (void)exportKeystore:(NSString *)passWord
            completion:(void(^)(BOOL suc,NSString *keystore,CCWalletError error))completion;

/**
 导出助记词
 
 @param passWord 密码
 @param completion 回调
 */
- (void)exportMnemonic:(NSString *)passWord
            completion:(void(^)(BOOL suc,NSString *mnemonic,CCWalletError error))completion;


/**
 展示的筛选条件修改

 @param type 筛选条件
 */
- (void)changeFilterType:(NSString *)type;


/**
 是否隐藏无余额

 @param hideNoBalance 是否隐藏
 */
- (void)changeHideNoBalance:(BOOL)hideNoBalance;

/**
 余额显示

 @return 余额显示
 */
- (NSString *)balanceString;


/**
 添加资产

 @param asset 资产
 */
- (void)addAsset:(CCTokenInfoModel *)asset;

/**
 批量添加有余额的资产

 @param assets 资产数组
 @param noContains 本地没有包含在其中的资产
 @param completion 回调
 */
- (void)addAssetArray:(NSArray <CCTokenInfoModel *> *)assets
           noContains:(void(^)(NSArray <CCAsset *>*))noContains
           completion:(void(^)(void))completion;

/**
 删除资产

 @param asset 资产
 */
- (void)deleteAsset:(CCAsset *)asset;


/**
 资产是否被添加过

 @param asset 资产
 @return 之前添加的
 */
- (CCAsset *)hadAddAsset:(CCTokenInfoModel *)asset;


/**
 切换币种单位
 */
- (void)changeCurrencyUnit;

/**
 钱包的地址的区块浏览器地址
 
 @return 地址
 */
-(NSString *)addressExplorer;


/**
 交易记录详情Url
 
 @param txId txid
 @return url
 */
- (NSString *)tradeDetailUrlWithTxId:(NSString *)txId;


/**
 修改名称

 @param walletName 名称
 */
- (void)changeWalletName:(NSString *)walletName;


/**
 修改余额

 @param balance 余额
 */
- (void)changeWalletBalance:(NSString *)balance;



/**
 查询资产余额&价格
 
 @param completion 回调
 */
- (void)queryAssetBalanceCompletion:(void(^)(void))completion;

- (void)queryBalanceWithAsset:(NSArray *)assets completion:(void(^)(void))completion;

/**
 查询钱包下有余额的资产
 
 @param completion 回调
 @param noContain 返回不在其中不含的资产
 */
- (void)queryAssetHoldingCompletion:(void(^)(void))completion noContain:(void(^)(NSArray <CCAsset *> *noContains))noContain;

/**
 查询单个

 @param asset asset
 @param completion 回调
 */
- (void)queryAssetBalance:(CCAsset *)asset completion:(void(^)(void))completion;


/**
 获取资产

 @param token tokenAddress
 @return 资产
 */
- (CCAsset *)assetWithToken:(NSString *)token;
- (CCAsset *)assetWithSymbol:(NSString *)symbol;

/**
 默认icon

 @return 默认icon
 */
- (NSString *)defaultIcon;


/**
 对应资产加载对应图片

 @param imageView 图片
 @param asset 资产
 */
- (void)bindImageView:(UIImageView *)imageView asset:(CCAsset *)asset;


/**
 提取的币种

 @return 币种
 */
- (NSString *)claimSymbol;


/**
 查询资产价格

 @param synbols 资产
 @param completion 回调
 */
- (void)queryPriceSynbols:(NSArray *)synbols completion:(void(^)(NSDictionary *result))completion;




/**
 资产余额

 @param asset asset
 @return 资产余额
 */
+ (NSString *)balanceStringWithAsset:(CCAsset *)asset;

/**
 计算价格

 @param asset asset
 @return 计算后价格
 */
+ (NSString *)priceBalanceStringWithAsset:(CCAsset *)asset;


/**
 检查地址是否符合规则
 
 @param address 地址
 @param coinType 链
 @return 结果
 */
+ (BOOL)checkAddress:(NSString *)address coinType:(CCCoinType)coinType;


/**
 检验是否是CK猫

 @param asset 资产
 @return 结果
 */
+ (BOOL)checkIsCryptoKittiesAsset:(CCAsset *)asset;


/**
 检验交易记录是不是NEO或者NEO gas的

 @return BOOL
 */
+ (BOOL)isNEOOrNEOGas:(NSString *)tokenAddress;

@end
