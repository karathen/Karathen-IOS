//
//  CCHardwareWallet.h
//  karathen
//
//  Created by MengLiMing on 2018/11/22.
//  Copyright © 2018 raistone. All rights reserved.
//

///硬件钱包
#import <Foundation/Foundation.h>
#import "Utils.h"

@interface CCHardwareWallet : NSObject

@property (nonatomic, assign, readonly) BOOL isConnectDevice;
@property (nonatomic, strong, readonly) NSString *deviceName;

@property (nonatomic, copy) void(^deviceWaiting)(void);

/**
 当前设备连接的硬件

 @return 钱包
 */
+ (CCHardwareWallet *)hardwareWallet;


/**
 重置设备
 */
- (void)resetDevice;

/**
 第一次打开应用时，
 */
- (void)bindHardwareAccount;
- (void)changeDeviceWithAccount:(CCAccountData *)accountData;


/**
 连接设备
 
 @param deviceName 设备名
 @param completion 回调
 */
- (void)connectDevice:(NSString *)deviceName
           completion:(void(^)(BOOL success, int errorCode, NSInteger saveDevice))completion;


/**
 断开设备
 
 @param completion 回调
 */
- (void)disconnectDeviceCompletion:(void(^)(BOOL success, int errorCode))completion;

/**
 硬件支持的链

 @return 链
 */
+ (NSArray *)hardwareCoins;

/**
 重连设备

 @param completion 回调
 */
- (void)reConnectDeviceCompletion:(void(^)(BOOL success, int errorCode))completion;


/**
 重置设备
 
 @param completion 回调
 @param deviceWaiting 等待
 */
- (void)formatDeviceCompletion:(void(^)(BOOL success, int errorCode))completion
                 deviceWaiting:(void(^)(void))deviceWaiting;


/**
 清空屏幕

 @param completion 回调
 */
- (void)clearScreenCompletion:(void(^)(BOOL success, int errorCode))completion;


/**
 关闭钱包

 @param completion 回调
 */
- (void)powerOffCompletion:(void(^)(BOOL success, int errorCode))completion;

/**
 生成随机助记词
 
 @param completion 回调
 */
- (void)generateSeedCompletion:(void(^)(BOOL success, int errorCode, NSString *mnemnoic))completion;


/**
 助记词写入
 
 @param mnemonic 助记词
 @param completion 回调
 */
- (void)importSeedWithMnemonic:(NSString *)mnemonic
                    completion:(void(^)(BOOL success, int errorCode))completion;

/**
 通过助记词得到Eth地址

 @param mnemonic 助记词
 @param slot slot
 @param completion 回调
 */
- (void)getETHAddressFromMnemonic:(NSString *)mnemonic
                             slot:(int)slot
                       completion:(void(^)(BOOL suc, int errorCode, NSString *address))completion;


/**
 获取当前设备的ETH地址

 @param slot slot
 @param showScreen 是否显示在屏幕上
 @param deviceWaiting block
 @param completion 回调
 */
- (void)getETHDeviceAddressWithSlot:(int)slot
                         showScreen:(BOOL)showScreen
                      deviceWaiting:(void(^)(void))deviceWaiting
                         completion:(void(^)(BOOL suc, int errorCode, NSString *address))completion;



/**
 获取设备支持链下的地址

 @param completion 回调
 */
- (void)getDeviceAddressCompletion:(void(^)(BOOL suc, int errorCode, NSDictionary *addressDic))completion;

- (void)getDeviceAddressCoins:(NSArray *)coins
                         slot:(int)slot
                   completion:(void(^)(BOOL suc, int errorCode, NSDictionary *addressDic))completion;

/**
 ETH签名交易

 @param data 交易
 @param slot slot
 @param asset asset
 @param verifyFp 是否验证指纹
 @param password 密码
 @param deviceWaiting block
 @param completion 回调
 */
- (void)signETHTransaction:(NSData *)data
                      slot:(int)slot
                     asset:(CCAsset *)asset
                  verifyFp:(BOOL)verifyFp
                  password:(NSString *)password
             deviceWaiting:(void(^)(void))deviceWaiting
                completion:(void(^)(BOOL suc, int errorCode, NSData *signData))completion;



/**
 初始化密码

 @param passWord 密码
 @param deviceWaiting wait
 @param completion 回调
 */
- (void)initPassword:(NSString *)passWord
       deviceWaiting:(void(^)(void))deviceWaiting
          completion:(void(^)(BOOL suc, int errorCode))completion;


/**
 验证密码

 @param passWord 密码
 @param completion 回调
 */
- (void)verifyPassword:(NSString *)passWord
            completion:(void(^)(BOOL suc, int errorCode))completion;


/**
 修改密码

 @param passWord 新密码
 @param oldPassWord 老密码
 @param deviceWaiting wait
 @param completion 回调
 */
- (void)changePassword:(NSString *)passWord
           oldPassWord:(NSString *)oldPassWord
         deviceWaiting:(void(^)(void))deviceWaiting
            completion:(void(^)(BOOL suc, int errorCode))completion;


/**
 录入指纹
 
 @param progress 进度
 @param completion 回调
 */
- (void)enrollFPProgress:(void(^)(CGFloat progress))progress
              completion:(void(^)(BOOL suc, int errorCode))completion;

/**
 取消录入指纹
 
 @param completion 回调
 */
- (void)abortFPActionCompletion:(void(^)(BOOL suc, int errorCode))completion;

/**
 验证指纹

 @param completion 回调
 */
- (void)verifyFPCompletion:(void(^)(BOOL suc, int errorCode))completion;

/**
 删除指纹

 @param completion 回调
 */
- (void)deleteFPCompletion:(void(^)(BOOL suc, int errorCode))completion;



@end
