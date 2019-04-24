//
//  CCTradeDetailTableViewCell.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBottomLineTableViewCell.h"

@interface CCTradeDetailTableViewCell : CCBottomLineTableViewCell

@property (nonatomic, copy) void(^copyTxid)(void);
- (void)bindCellWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image color:(UIColor *)color;

@end
