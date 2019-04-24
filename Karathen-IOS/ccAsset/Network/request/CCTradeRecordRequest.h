//
//  CCTradeRecordRequest.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/24.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRequest.h"
#import "CCTradeRecord+CoreDataClass.h"

@class CCTradeRecordModel;



typedef void(^loadFinish)(NSArray *addArray);

@interface CCTradeRecordRequest : NSObject

@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) CCCoinType coinType;

@property (nonatomic, assign) BOOL hadMore;
@property (nonatomic, strong, readonly) NSMutableArray <CCTradeRecordModel *> *dataArray;


- (void)headRefreshBlock:(loadFinish)block;
- (void)footRefreshBlock:(loadFinish)block;

@end

