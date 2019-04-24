//
//  ONTLong.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/25.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONTLong : NSObject
@property (nonatomic,assign) long value;
/**
 * @brief Initialization method
 */
- (instancetype)initWithLong:(long)l;
@end
