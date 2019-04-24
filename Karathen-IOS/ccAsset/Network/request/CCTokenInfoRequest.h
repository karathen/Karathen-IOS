//
//  CCTokenInfoRequest.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRequest.h"

@class CCTokenInfoModel;
@interface CCTokenInfoRequest : CCRequest

@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, strong) NSString *coinType;

- (void)requestCompletion:(void(^)(NSArray <CCTokenInfoModel *> *))completion;

@end


@interface CCTokenInfoModel : NSObject

@property (nonatomic, strong) NSString *tokenAddress;
@property (nonatomic, strong) NSString *tokenDecimal;
@property (nonatomic, strong) NSString *tokenIcon;
@property (nonatomic, strong) NSString *tokenName;
@property (nonatomic, strong) NSString *tokenSynbol;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, strong) NSString *balance;

@end
