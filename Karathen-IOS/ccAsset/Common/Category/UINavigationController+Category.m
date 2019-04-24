//
//  UINavigationController+Category.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/28.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "UINavigationController+Category.h"

@implementation UINavigationController (Category)

- (void)deleteFrontVC {
    NSMutableArray *arr = [self.viewControllers mutableCopy];
    [arr removeObjectAtIndex:arr.count-2];
    self.viewControllers = arr;
    if (arr.count == 2) {
        UIViewController *vc = arr.lastObject;
        vc.hidesBottomBarWhenPushed = YES;
    }
}

@end
