//
//  CCErc721TokenInfoModel.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/15.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCErc721TokenInfoModel : NSObject

@property (nonatomic, strong) NSString *tokenId;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSDictionary *data;


/**
 图片

 @param asset 资产
 @return 地址
 */
- (NSString *)tokenIconWithAsset:(CCAsset *)asset;

+ (NSString *)tokenIconWithAsset:(CCAsset *)asset tokenId:(NSString *)tokeId;

/**
 CK猫的速度

 @return 速度
 */
- (NSString *)ckSpeed;

/**
 代数

 @return 代
 */
- (NSString *)ckGeneration;

@end


