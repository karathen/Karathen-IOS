//
//  CCDAppBrowserWKVC+JS.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/17.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCDAppBrowserWKVC.h"

@interface CCDAppBrowserWKVC (JS)

- (void)setDefaultAccountFinish:(void(^)(void))finish;
- (void)callAfterReload;

/**
 js调用oc
 */
- (void)jsCallOc;


/**
 oc调用js
 */
- (void)ocCallJs;

@end
