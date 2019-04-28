//
//  CCAddressManageView.h
//  Karathen
//
//  Created by Karathen on 2018/9/5.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"

typedef NS_ENUM(NSInteger, CCAddressManageType) {
    CCAddressManageOther = 0,//其他
    CCAddressManageKeystore,//导出keystore
    CCAddressManagePrivateKey,//导出私钥
    CCAddressManageWIF,//导出WIF
    CCAddressManageName,//修改名称
    CCAddressManageInternet,//浏览器查询
    CCAddressManageDelete,//删除地址
    CCAddressManageClaimGas,//提取GAS
};


@protocol CCAddressManageViewDelegate <NSObject>

@optional
- (void)addressManageWithType:(CCAddressManageType)type walletData:(CCWalletData *)walletData;

@end

@interface CCAddressManageView : MLMOptionSelectView

@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, weak) id<CCAddressManageViewDelegate> manageDelegate;

- (void)showTargetView:(UIView *)view;

@end


@interface CCAddressManageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLab;

@end
