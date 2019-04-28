//
//  CCGetTxRemarkRequest.h
//  Karathen
//
//  Created by Karathen on 2018/9/20.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRequest.h"

@interface CCGetTxRemarkRequest : CCRequest

@property (nonatomic, strong) NSString *txId;

- (void)requestCompletion:(void(^)(NSString *remark))completion;

@end
