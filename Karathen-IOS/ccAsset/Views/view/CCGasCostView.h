//
//  CCGasCostView.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCGasCostView : UIView

- (instancetype)initWithAsset:(CCAsset *)asset gasPrice:(NSString *)gasPrice;

- (instancetype)initWithAsset:(CCAsset *)asset gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit;


- (void)changeGasPrice:(NSString *)gasPrice;

//
- (NSString *)currentGasPrice;

@end
