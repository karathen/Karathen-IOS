//
//  CCStockConstant.h
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#ifndef CCStockConstant_h
#define CCStockConstant_h

typedef NS_ENUM(NSInteger, CCAppChannel) {
    CCAppChannelAppstore = 0,//AppStore
    CCAppChannelEnterprise = 1,//企业签名
};

typedef NS_ENUM(NSInteger, CCCoinType) {
    CCCoinTypeNone = -1,//当前没有选择的链
    CCCoinTypeETH = 60,//ETH
    CCCoinTypeNEO = 888,//NEO
    CCCoinTypeONT = 1024,//ONT
};


/**
 钱包类型
 */
typedef NS_ENUM(NSInteger, CCWalletType) {
    CCWalletTypePhone = 2,//手机钱包
    CCWalletTypeHardware = 3,//硬件钱包
};

/**
 导入方式
 */
typedef NS_ENUM(NSInteger, CCImportType) {
    CCImportTypeSeed = 1,//种子
    CCImportTypeMnemonic = 2,//助记词
    CCImportTypeKeystore = 3,//keyStore
    CCImportTypePrivateKey = 4,//私钥
    CCImportTypeWIF = 5,//WIF
    CCImportTypeHardware = 6,//硬件
};

//notify
#define CC_ACCOUNT_CHANGE_NOTIFICATION @"CC_Account_Change_Notification"  //账户变化通知
#define CC_ACTIVE_ACCOUNT_CHANGE_NOTIFICATION @"CC_Active_Account_Change_Notification"  //活跃账户变化通知
#define CC_ACCOUNT_NAME_CHANGE_NOTIFICATION @"CC_Account_Name_Change_Notification"  //账户名称变化通知
#define CC_ACCOUNT_BACKUP_NOTIFICATION @"CC_Account_Backup_Notification"  //账户备份通知
#define CC_Coin_Manage_CHANGE_NOTIFICATION @"CC_Coin_Manage_Change_Notification"  //链管理
#define CC_COIN_WALLETSELECT_CHANGE_NOTIFICATION @"CC_Coin_WalletSelect_Change_Notification"  //链默认地址切换
#define CC_WALLET_FILTER_CHANGE_NOTIFICATION @"CC_Wallet_Filter_Change_Notification"  //钱包筛选条件切换
#define CC_WALLET_HIDENOBALANCE_NOTIFICATION @"CC_Wallet_HideNoBalance_Notification"  //钱包隐藏无余额切换
#define CC_WALLET_ADDRESS_CHANGE_NOTIFICATION @"CC_Wallet_Address_Change_Notification"  //添加地址通知
#define CC_ASSET_CHANGE_NOTIFICATION @"CC_Asset_Change_Notification"  //资产变动通知
#define CC_ASSET_TRADE_Update_NOTIFICATION @"CC_ASSET_TRADE_Update_NOTIFICATION"  //新增加交易通知
#define CC_WALLET_BALANCE_CHANGE_NOTIFICATION @"CC_Wallet_Balance_Change_Notification"  //钱包余额变化通知
#define CC_WALLET_NAME_CHANGE_NOTIFICATION @"CC_Wallet_Name_Change_Notification"  //钱包名变化通知
#define CC_CURRENCYUNIT_CHANGE_NOTIFICATION @"CC_CurrencyUnit_Change_Notification"  //货币单位切换通知
#define CC_BLOCKHEIGHT_REFRESH_NOTIFICATION @"CC_BlockHeight_Refresh_Notification"  //块高刷新
#define CC_BLUETOOTH_STATE_CHANGE_NOTIFICATION @"CC_BlueTooth_State_Change_Notification"  //蓝牙状态通知

//userDefault
/** 存储当前选择的语言 */
#define CCKeyForCurrentLanguage @"CCAppCurrentLanguage"
/** 当前选择的货币种类 */
#define CC_CURRENT_CURRENCYUNIT @"cc_current_currencyUnit"
/** 当前清空数据库的版本 */
#define CC_CURRENT_CLEARDATA_VERSION @"cc_current_clearData_version"

//app
#define Karathen_URL @""
#define Karathen_EMail @""

//七牛图片地址
#define CC_QINIU_IMAGE @""

//coreData存储
#define CC_COREDATA_SQLITE @"demo.sqlite"
//钥匙串
#define CCWalletDataServiceName @"demo.keychain"

//
#define CCAppBase_URL @""

//ETH区块浏览器
#define CC_ETH_ADDRESS_URL @""
#define CC_ETH_TX_URL @""

//NEO区块浏览器
#define CC_NEO_ADDRESS_URL @""
#define CC_NEO_TX_URL @""

//ONT区块浏览器
#define CC_ONT_ADDRESS_URL @""
#define CC_ONT_TX_URL @""

//ONT
#define CC_ONT_BASEURL @""
#define CC_ONT_NODE @""
#define CC_ONT_EXPLORER @""

//ETH
#define CC_ETH_APIKEY @""
#define CC_ETH_BASEURL @""
#define CC_ETH_EXPLORER @""

//NEO
#define CC_NEO_BASEURL @""
#define CC_NEO_EXPLORER @""

#endif /* CCStockConstant_h */
