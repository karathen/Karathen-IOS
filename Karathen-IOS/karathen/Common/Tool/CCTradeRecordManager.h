//
//  CCTradeRecordManager.h
//  Karathen
//
//  Created by Karathen on 2018/8/2.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTradeRecordManager : NSObject


/**
 本地记录
 */
@property (nonatomic, strong) NSArray *localData;


- (instancetype)initWithWallet:(CCWalletData *)walletData
                  tokenAddress:(NSString *)tokenAddress;

- (void)requsetLocalData;

@end
