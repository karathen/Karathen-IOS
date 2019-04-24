//
//  CCTXRemarkRequest.h
//  ccAsset
//
//  Created by 孟利明 on 2018/8/8.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRequest.h"

@interface CCTXRemarkRequest : CCRequest

@property (nonatomic, strong) NSString *txId;
@property (nonatomic, strong) NSString *remark;

- (void)requestCompletion:(void(^)(BOOL suc))completion;

@end
