//
//  UIView+TapBlock.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "UIView+TapBlock.h"
#import <objc/runtime.h>

static char tapKey;

@implementation UIView (TapBlock)

- (void)cc_tapHandle:(CC_TapAction)block {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    objc_setAssociatedObject(self, &tapKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    CC_TapAction blcok = objc_getAssociatedObject(self, &tapKey);
    if (blcok) {
        blcok();
    }
}

+ (void)endEdit {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

@end
