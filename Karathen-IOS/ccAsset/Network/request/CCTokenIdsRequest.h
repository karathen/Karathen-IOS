//
//  CCTokenIdsRequest.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/15.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCTokenIdsRequest : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *tokenAddress;
@property (nonatomic, assign) BOOL hadMore;
@property (nonatomic, strong, readonly) NSMutableArray *dataArray;

- (void)headRefreshBlock:(void(^)(void))block;
- (void)footRefreshBlock:(void(^)(void))block;

@end
