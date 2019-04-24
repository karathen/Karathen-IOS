//
//  CCHardwareWallet.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/22.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCHardwareWallet.h"
#import <iOS_EWalletDynamic/PA_EWallet.h>
#import "StructHeaderFile.h"
#import "CCHardwareScanner.h"

@interface CCHardwareWallet () <CCHardwareScannerDelegate>

@property (nonatomic, assign) NSInteger savedDevice;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) CCHardwareScanner *hardwareScanner;

@property (nonatomic, assign) BOOL isConnectDevice;
@property (nonatomic, copy) void(^reConnectCompletion)(BOOL success);

//输入的密码
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) int authType;
@property (nonatomic, assign) int lastSignState;

//取消
@property (nonatomic, assign) BOOL abortBtnState;
//取消事件锁
@property (nonatomic, strong) NSCondition *abortCondition;
@property (nonatomic, copy) void(^abortHandelBlock)(BOOL abortState);

@end

@implementation CCHardwareWallet

static CCHardwareWallet *wallet =nil;

#pragma mark - 当前设备连接的硬件
+ (CCHardwareWallet *)hardwareWallet {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wallet = [[CCHardwareWallet alloc] init];
        [wallet addNotify];
    });
    return wallet;
}

- (void)addNotify {
    [self changeDeviceWithAccount:[CCDataManager dataManager].activeAccount];

    @weakify(self)
    [CCNotificationCenter receiveActiveAccountChangeObserver:self completion:^{
        @strongify(self)
        [self changeDeviceWithAccount:[CCDataManager dataManager].activeAccount];
    }];
}

- (void)changeDeviceWithAccount:(CCAccountData *)accountData {
    if (accountData.account.walletType != CCWalletTypeHardware) {
        return;
    }
    NSString *deviceName = [[CCDataManager dataManager] walletInfoWithAccountID:accountData.account.accountID];
    if ([deviceName isEqualToString:self.deviceName]) {
        return;
    }
    
    self.deviceName = deviceName;
    self.savedDevice = 0;
}

- (void)setSavedDevice:(NSInteger)savedDevice {
    _savedDevice = savedDevice;
    if (savedDevice == 0) {
        self.isConnectDevice = NO;
    } else {
        self.isConnectDevice = YES;
    }
}

#pragma mark - 初次打开应用时，调用一次
- (void)bindHardwareAccount {
    [self changeDeviceWithAccount:[CCDataManager dataManager].activeAccount];
}

#pragma mark - 硬件支持的链
+ (NSArray *)hardwareCoins {
    return @[
             @(CCCoinTypeETH)
             ];
}


#pragma mark - 连接设备
void *savedDevH;//device handle

- (void)connectDevice:(NSString *)deviceName
           completion:(void(^)(BOOL success, int errorCode, NSInteger saveDevice))completion {
    if ([deviceName isEqualToString:self.deviceName] && self.isConnectDevice) {
        completion(YES,0,self.savedDevice);
    } else {
        char *szDeviceName = (char *)[deviceName UTF8String];
        __block ConnectContext additional = {0};
        additional.timeout = 5;
        additional.batteryCallBack = BatteryCallback;
        additional.disconnectedCallback = DisconnectedCallback;
        __block void *ppPAEWContext = 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int connectDev = PAEW_InitContextWithDevNameAndDevContext(&ppPAEWContext, szDeviceName, PAEW_DEV_TYPE_BT, &additional, sizeof(additional), 0x00, 0x00);
            if (ppPAEWContext) {
                savedDevH = ppPAEWContext;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (connectDev == PAEW_RET_SUCCESS) {
                    NSInteger savedDevice = (uint64_t)savedDevH;
                    self.deviceName = deviceName;
                    self.savedDevice = savedDevice;
                    if (completion) {
                        completion(YES,0,savedDevice);
                    }
                } else {
                    if (completion) {
                        completion(NO,connectDev,0);
                    }
                }
            });
        });
    }
}

int BatteryCallback(const int nBatterySource, const int nBatteryState)
{
    DLog(@"current battery source is: %d, current battery state is: 0x%X", nBatterySource, nBatteryState);
    return PAEW_RET_SUCCESS;
}

int DisconnectedCallback(const int status, const char *description)
{
    DLog(@"device has disconnected already, status code is: %d, detail is: %s", status, description);
    if (wallet != nil) {
        wallet.isConnectDevice = NO;
    }
    return PAEW_RET_SUCCESS;
}


#pragma mark - 重连
- (void)reConnectDeviceCompletion:(void(^)(BOOL success, int errorCode))completion {
    if (self.deviceName == nil) {
        if (completion) {
            completion(NO,PAEW_RET_UNKNOWN_FAIL);
        }
        return;
    }
    
    @weakify(self)
    self.reConnectCompletion = ^(BOOL success) {
        @strongify(self)
        if (success) {
            [self connectDevice:self.deviceName completion:^(BOOL success, int errorCode, NSInteger saveDevice) {
                @strongify(self)
                DLog(@"error - %@",[Utils errorCodeToString:errorCode]);
                if (success) {
                    self.savedDevice = saveDevice;
                }
                if (completion) {
                    completion(success,errorCode);
                }
            }];
        } else {
            if (completion) {
                completion(NO, PAEW_RET_UNKNOWN_FAIL);
            }
        }
    };
    
    [self.hardwareScanner scanHardwareDevices];
}

- (void)scanDeviceEndWithScanner:(CCHardwareScanner *)scanner {
    if (!self.isConnectDevice) {
        self.reConnectCompletion(NO);
    }
}

- (void)hardwareDevicesChangeWithScanner:(CCHardwareScanner *)scanner {
    CCHardwareDevice *currentDevice;
    for (CCHardwareDevice *device in scanner.devices) {
        if ([device.peripheralName isEqualToString:self.deviceName]) {
            currentDevice = device;
            break;
        }
    }
    if (currentDevice) {
        self.reConnectCompletion(YES);
    }
}

- (void)scanDeviceFailWithScanner:(CCHardwareScanner *)scanner {
    self.reConnectCompletion(NO);
}

#pragma mark - 重置设备
- (void)formatDeviceCompletion:(void(^)(BOOL success, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        
        iRtn = PAEW_Format(ppPAEWContext, devIdx);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
            return ;
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}

#pragma mark - 清空屏幕
- (void)clearScreenCompletion:(void(^)(BOOL success, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        iRtn = PAEW_ClearLCD(ppPAEWContext, devIdx);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
            return ;
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}

#pragma mark - 关闭钱包
- (void)powerOffCompletion:(void(^)(BOOL success, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        iRtn = PAEW_PowerOff(ppPAEWContext, devIdx);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
            return ;
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}

#pragma mark - 生成随机助记词
- (void)generateSeedCompletion:(void(^)(BOOL success, int errorCode, NSString *mnemnoic))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        unsigned char nSeedLen = 16;
        unsigned char pbMneWord[PAEW_MNE_MAX_LEN] = {0};
        size_t pnMneWordLen = sizeof(pbMneWord);
        size_t  pnCheckIndex[PAEW_MNE_INDEX_MAX_COUNT] = { 0 };
        size_t pnCheckIndexCount = PAEW_MNE_INDEX_MAX_COUNT;
        iRtn = PAEW_GenerateSeed_GetMnes(ppPAEWContext, devIdx, nSeedLen, pbMneWord, &pnMneWordLen, pnCheckIndex, &pnCheckIndexCount);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO,iRtn,nil);
            }
            return;
        }
        NSString *mnemonic = [NSString stringWithFormat:@"%s",pbMneWord];
        if (completion) {
            completion(YES,0,mnemonic);
        }
    });
}

#pragma mark - 助记词写入
- (void)importSeedWithMnemonic:(NSString *)mnemonic
                    completion:(void(^)(BOOL success, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        
        int iRtn = PAEW_ImportSeed(ppPAEWContext, devIdx, (const unsigned char *)[mnemonic UTF8String], mnemonic.length);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}

#pragma mark - 通过助记词得到ETH地址
- (void)getETHAddressFromMnemonic:(NSString *)mnemonic
                             slot:(int)slot
                       completion:(void(^)(BOOL suc, int errorCode, NSString *address))completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned char bSeedData[1024] = {0};
        size_t nSeedLen = 64;
        unsigned char bPrivKey[1024] = {0};
        size_t nPrivKeyLen = 1024;
        unsigned char bAddress[1024] = {0};
        size_t nAddressLen = 1024;
        int iRtn = PAEW_RecoverSeedFromMne((const unsigned char *)[mnemonic UTF8String], mnemonic.length, bSeedData, &nSeedLen);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn, nil);
            }
        } else {
            uint32_t puiDerivePathETH[] = {0, 0x8000002c, 0x8000003c, 0x80000000, 0x00000000, slot};
            
            iRtn = PAEW_GetTradeAddressFromSeed(bSeedData, nSeedLen, puiDerivePathETH, sizeof(puiDerivePathETH)/sizeof(puiDerivePathETH[0]), bPrivKey, &nPrivKeyLen, 0, PAEW_COIN_TYPE_ETH, bAddress, &nAddressLen);
            if (iRtn != PAEW_RET_SUCCESS) {
                if (completion) {
                    completion(NO, iRtn, nil);
                }
            } else {
                NSString *address = [NSString stringWithUTF8String:(char *)bAddress];
                if (![address hasPrefix:@"0x"]) {
                    address = [NSString stringWithFormat:@"0x%@",address];
                }
                if (completion) {
                    completion(YES,0,address);
                }
            }
        }
        
    });
}

#pragma mark - 获取当前设备的ETH地址
- (void)getETHDeviceAddressWithSlot:(int)slot
                         showScreen:(BOOL)showScreen
                         completion:(void(^)(BOOL suc, int errorCode, NSString *address))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        unsigned char bAddress[1024] = {0};
        size_t nAddressLen = 1024;
        
        uint32_t puiDerivePathETH[] = {0, 0x8000002c, 0x8000003c, 0x80000000, 0x00000000, slot};
        iRtn = PAEW_DeriveTradeAddress(ppPAEWContext, devIdx, PAEW_COIN_TYPE_ETH, puiDerivePathETH, sizeof(puiDerivePathETH)/sizeof(puiDerivePathETH[0]));
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn, nil);
            }
        } else {
            unsigned char showOnScreen = 0;
            if (showScreen) {
                showOnScreen = 1;
            }
            iRtn = PAEW_GetTradeAddress(ppPAEWContext, devIdx, PAEW_COIN_TYPE_ETH, showOnScreen, bAddress, &nAddressLen);
            if (iRtn != PAEW_RET_SUCCESS) {
                if (completion) {
                    completion(NO, iRtn, nil);
                }
            } else {
                if (showScreen) {
                    PAEW_ClearLCD(ppPAEWContext, devIdx);
                }
                NSString *address = [NSString stringWithUTF8String:(char *)bAddress];
                if (![address hasPrefix:@"0x"]) {
                    address = [NSString stringWithFormat:@"0x%@",address];
                }
                if (completion) {
                    completion(YES,0,address);
                }
            }
        }
    });
}

#pragma mark - 获取地址下各链的地址
- (void)getDeviceAddressCompletion:(void(^)(BOOL suc, int errorCode, NSDictionary *addressDic))completion {
    NSArray *coins = [CCHardwareWallet hardwareCoins];
    [self getDeviceAddressCoins:coins slot:0 completion:completion];
}

- (void)getDeviceAddressCoins:(NSArray *)coins slot:(int)slot completion:(void(^)(BOOL suc, int errorCode, NSDictionary *addressDic))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        unsigned char bAddress[1024] = {0};
        size_t nAddressLen = 1024;
        
        NSInteger currentIndex = 0;
        NSMutableDictionary *addressDic = [NSMutableDictionary dictionary];
        
        do {
            nAddressLen = 1024;
            memset(bAddress, 0, 1024);
            
            NSInteger currentCoinType = [coins[currentIndex] integerValue];
            int coinType = PAEW_COIN_TYPE_INVALID;
            uint32_t puiDerivePath[] = {0, 0, 0, 0, 0, 0};
            if (currentCoinType == CCCoinTypeETH) {
                coinType = PAEW_COIN_TYPE_ETH;
                uint32_t puiDerivePathETH[] = {0, 0x8000002c, 0x8000003c, 0x80000000, 0x00000000, slot};
                puiDerivePath[0] = puiDerivePathETH[0];
                puiDerivePath[1] = puiDerivePathETH[1];
                puiDerivePath[2] = puiDerivePathETH[2];
                puiDerivePath[3] = puiDerivePathETH[3];
                puiDerivePath[4] = puiDerivePathETH[4];
                puiDerivePath[5] = puiDerivePathETH[5];
            } else if (currentCoinType == CCCoinTypeNEO) {
                coinType = PAEW_COIN_TYPE_NEO;
                const uint32_t puiDerivePathNEO[] = {0, 0x8000002c, 0x80000378, 0x80000000, 0x00000000, slot};
                puiDerivePath[0] = puiDerivePathNEO[0];
                puiDerivePath[1] = puiDerivePathNEO[1];
                puiDerivePath[2] = puiDerivePathNEO[2];
                puiDerivePath[3] = puiDerivePathNEO[3];
                puiDerivePath[4] = puiDerivePathNEO[4];
                puiDerivePath[5] = puiDerivePathNEO[5];
            }
            
            iRtn = PAEW_DeriveTradeAddress(ppPAEWContext, devIdx, coinType, puiDerivePath, sizeof(puiDerivePath)/sizeof(puiDerivePath[0]));
            if (iRtn == PAEW_RET_SUCCESS) {
                iRtn = PAEW_GetTradeAddress(ppPAEWContext, devIdx, coinType, 0, bAddress, &nAddressLen);
                if (iRtn == PAEW_RET_SUCCESS) {
                    NSString *address = [NSString stringWithUTF8String:(char *)bAddress];
                    if (![address hasPrefix:@"0x"]) {
                        address = [NSString stringWithFormat:@"0x%@",address];
                    }
                    [addressDic setValue:address forKey:[CCDataManager coinKeyWithType:currentCoinType]];
                }
            } else {
                break;
            }
            currentIndex += 1;
        } while (currentIndex < coins.count);
        if (iRtn == PAEW_RET_SUCCESS) {
            if (completion) {
                completion(YES,iRtn,addressDic);
            }
        } else {
            if (completion) {
                completion(NO,iRtn,nil);
            }
        }
    });
}


#pragma mark - ETH密码签名交易
- (void)signETHTransaction:(NSData *)data
                      slot:(int)slot
                     asset:(CCAsset *)asset
                  verifyFp:(BOOL)verifyFp
                  password:(NSString *)password
                completion:(void(^)(BOOL suc, int errorCode, NSData *signData))completion {
    self.password = verifyFp?nil:password;
    self.authType = verifyFp?PAEW_SIGN_AUTH_TYPE_FP:PAEW_SIGN_AUTH_TYPE_PIN;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        unsigned char nCoinType = PAEW_COIN_TYPE_ETH;
        uint32_t puiDerivePath[] = {0, 0x8000002c, 0x8000003c, 0x80000000, 0x00000000, slot};
        iRtn = PAEW_DeriveTradeAddress(ppPAEWContext, devIdx, nCoinType, puiDerivePath, sizeof(puiDerivePath)/sizeof(puiDerivePath[0]));
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn, nil);
            }
        } else {
            if ([asset.tokenType compareWithString:CCAseet_ETH_ERC20]) {
                int nPrecision = asset.tokenDecimal.intValue;
                iRtn = PAEW_SetERC20Info(ppPAEWContext, devIdx, PAEW_COIN_TYPE_ETH, [asset.tokenName UTF8String], nPrecision);
                if (iRtn != PAEW_RET_SUCCESS) {
                    if (completion) {
                        completion(NO, iRtn, nil);
                    }
                    return ;
                }
            }

            unsigned char transaction[[data length]];
            memcpy(transaction, [data bytes], [data length]);
            unsigned char *pbTXSig = (unsigned char *)malloc(1024);
            size_t pnTXSigLen = 1024;
            signCallbacks callBack;
            callBack.getAuthType = GetAuthType;
            callBack.getPIN = GetPin;
            callBack.putSignState = PutSignState;
            self.lastSignState = PAEW_RET_SUCCESS;
            iRtn = PAEW_ETH_TXSign_Ex(ppPAEWContext, devIdx, transaction, sizeof(transaction), pbTXSig,  &pnTXSigLen, &callBack, 0);
            if (iRtn != PAEW_RET_SUCCESS) {
                if (completion) {
                    completion(NO, iRtn, nil);
                }
                return ;
            } else {
                if (completion) {
                    completion(YES, 0, [NSData dataWithBytes:pbTXSig length:pnTXSigLen]);
                }
            }
        }
    });
}

int GetPin(void * const pCallbackContext, unsigned char * const pbPIN, size_t * const pnPINLen)
{
    if (wallet.password.length) {
        *pnPINLen = wallet.password.length;
        strcpy((char *)pbPIN, [wallet.password UTF8String]);
    }
    return PAEW_RET_SUCCESS;
}

int GetAuthType(void * const pCallbackContext, unsigned char * const pnAuthType)
{
    *pnAuthType = wallet.authType;
    return PAEW_RET_SUCCESS;
}

int PutSignState(void * const pCallbackContext, const int nSignState)
{
    if (nSignState != wallet.lastSignState) {
        wallet.lastSignState = nSignState;
    }
    //here is a good place to canel sign function
    if (wallet.abortBtnState) {
        [wallet.abortCondition lock];
        !wallet.abortHandelBlock ? : wallet.abortHandelBlock(YES);
        [wallet.abortCondition wait];
        [wallet.abortCondition unlock];
        wallet.abortBtnState = NO;
    }
    return 0;
}

#pragma mark - 初始化密码
- (void)initPassword:(NSString *)passWord
          completion:(void(^)(BOOL suc, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int initState = PAEW_InitPIN(ppPAEWContext, devIdx, [passWord UTF8String]);
        if (initState == PAEW_RET_SUCCESS) {
            if (completion) {
                completion(YES,0);
            }
        } else {
            if (completion) {
                completion(NO,initState);
            }
        }
    });
}


#pragma mark - 验证密码
- (void)verifyPassword:(NSString *)passWord
            completion:(void(^)(BOOL suc, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int initState = PAEW_VerifyPIN(ppPAEWContext, devIdx, [passWord UTF8String]);
        if (initState == PAEW_RET_SUCCESS) {
            if (completion) {
                completion(YES,0);
            }
        } else {
            if (completion) {
                completion(NO,initState);
            }
        }
    });
}

#pragma mark - 修改密码
- (void)changePassword:(NSString *)passWord
           oldPassWord:(NSString *)oldPassWord
            completion:(void(^)(BOOL suc, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int initState = PAEW_ChangePIN_Input(ppPAEWContext, devIdx, [oldPassWord UTF8String], [passWord UTF8String]);
        if (initState == PAEW_RET_SUCCESS) {
            if (completion) {
                completion(YES,0);
            }
        } else {
            if (completion) {
                completion(NO,initState);
            }
        }
    });
}

#pragma mark - 录入指纹
- (void)enrollFPProgress:(void(^)(CGFloat progress))progress
              completion:(void(^)(BOOL suc, int errorCode))completion {
    __block CGFloat progressNum = 0;
    CGFloat singleAdd = 1/50.0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int startEnrollS = PAEW_EnrollFP(ppPAEWContext, devIdx);
        if (startEnrollS != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, startEnrollS);
            }
            return ;
        }
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        int lastRtn = PAEW_RET_SUCCESS;
        do {
            
            iRtn = PAEW_GetFPState(ppPAEWContext, devIdx);
            if (lastRtn != iRtn) {
                if (progress) {
                    progress(progressNum += singleAdd);
                }
                lastRtn = iRtn;
            }
            if (self.abortBtnState) {
                [self.abortCondition lock];
                !self.abortHandelBlock ? : self.abortHandelBlock(YES);
                [self.abortCondition wait];
                [self.abortCondition unlock];
                self.abortBtnState = NO;
            }
        } while ((iRtn == PAEW_RET_DEV_WAITING) || (iRtn == PAEW_RET_DEV_FP_GOOG_FINGER) || (iRtn == PAEW_RET_DEV_FP_REDUNDANT) || (iRtn == PAEW_RET_DEV_FP_BAD_IMAGE) || (iRtn == PAEW_RET_DEV_FP_NO_FINGER) || (iRtn == PAEW_RET_DEV_FP_NOT_FULL_FINGER));
        if (iRtn != PAEW_RET_SUCCESS) {
            if (progress) {
                progress(0);
            }
            if (completion) {
                completion(NO, iRtn);
            }
            return ;
        } else {
            if (progress) {
                progress(1);
            }
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}


#pragma mark - 取消录入指纹
- (void)abortFPActionCompletion:(void(^)(BOOL suc, int errorCode))completion {
    self.abortBtnState = YES;
    __weak typeof(self) weakSelf = self;
    self.abortHandelBlock = ^(BOOL abortState) {
        if (!abortState) {
            return ;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int devIdx = 0;
            uint64_t temp = strongSelf.savedDevice;
            void *ppPAEWContext = (void*)temp;
            int iRtn = PAEW_RET_UNKNOWN_FAIL;
            
            strongSelf.abortBtnState = NO;
            iRtn = PAEW_AbortFP(ppPAEWContext, devIdx);
            [strongSelf.abortCondition lock];
            [strongSelf.abortCondition signal];
            [strongSelf.abortCondition unlock];
            
            if (iRtn != PAEW_RET_SUCCESS) {
                if (completion) {
                    completion(NO, iRtn);
                }
                return ;
            } else {
                if (completion) {
                    completion(YES, 0);
                }
            }
        });
    };
}

#pragma mark - 验证指纹
- (void)verifyFPCompletion:(void(^)(BOOL suc, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        iRtn = PAEW_VerifyFP(ppPAEWContext, devIdx);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
            return ;
        }
        
        int lastRtn = PAEW_RET_SUCCESS;
        do {
            iRtn = PAEW_GetFPState(ppPAEWContext, devIdx);
            if (lastRtn != iRtn) {
                lastRtn = iRtn;
            }
        } while (iRtn == PAEW_RET_DEV_WAITING);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
            return ;
        }
        
        size_t          nFPListCount = 1;
        FingerPrintID   *fpIDList = (FingerPrintID *)malloc(sizeof(FingerPrintID) * nFPListCount);
        memset(fpIDList, 0, sizeof(sizeof(FingerPrintID) * nFPListCount));
        iRtn = PAEW_GetVerifyFPList(ppPAEWContext, devIdx, fpIDList, &nFPListCount);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
        free(fpIDList);
    });
}

#pragma mark - 删除指纹
- (void)deleteFPCompletion:(void(^)(BOOL suc, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FingerPrintID   *localFPList = 0;
        int nFPCount = 0;
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        iRtn = PAEW_DeleteFP(ppPAEWContext, devIdx, localFPList, nFPCount);
        
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}

#pragma mark - 校准指纹
- (void)calibrateFPCompletion:(void(^)(BOOL suc, int errorCode))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devIdx = 0;
        void *ppPAEWContext = (void*)self.savedDevice;
        int iRtn = PAEW_RET_UNKNOWN_FAIL;
        iRtn = PAEW_CalibrateFP(ppPAEWContext, devIdx);
        if (iRtn != PAEW_RET_SUCCESS) {
            if (completion) {
                completion(NO, iRtn);
            }
        } else {
            if (completion) {
                completion(YES, 0);
            }
        }
    });
}



#pragma mark - get
- (NSCondition *)abortCondition {
    if (!_abortCondition) {
        _abortCondition = [[NSCondition alloc] init];
    }
    return _abortCondition;
}

- (CCHardwareScanner *)hardwareScanner {
    if (!_hardwareScanner) {
        _hardwareScanner = [[CCHardwareScanner alloc] init];
        _hardwareScanner.delegate = self;
    }
    return _hardwareScanner;
}

@end
