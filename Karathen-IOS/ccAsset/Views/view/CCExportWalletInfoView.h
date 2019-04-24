//
//  CCExportWalletInfoView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/18.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCExportWalletInfoView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) NSString *info;

- (void)showView;
- (void)showViewInView:(UIView *)view;
- (void)hiddenView;

@end
