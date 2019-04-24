//
//  UIView+TapBlock.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CC_TapAction)(void);

@interface UIView (TapBlock)

- (void)cc_tapHandle:(CC_TapAction)block;

+ (void)endEdit;

@end
