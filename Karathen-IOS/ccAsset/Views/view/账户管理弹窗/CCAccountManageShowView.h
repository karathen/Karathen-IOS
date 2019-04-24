//
//  CCAccountManageView.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"

typedef NS_ENUM(NSInteger, CCAccountManageType) {
    CCAccountManageTypeOther = 0,//其他
    CCAccountManageTypeName,//修改名称
    CCAccountManageTypePwd,//修改密码
    CCAccountManageTypePwdInfo,//密码提示
    CCAccountManageTypeCoin,//多链管理
    CCAccountManageTypeBackup,//备份
    CCAccountManageTypeDelete,//删除
};


@protocol CCAccountManageViewDelegate <NSObject>

@optional
- (void)accountManageWithType:(CCAccountManageType)type accountData:(CCAccountData *)accountData;

@end

@interface CCAccountManageShowView : MLMOptionSelectView

@property (nonatomic, weak) CCAccountData *accountData;
@property (nonatomic, weak) id<CCAccountManageViewDelegate> manageDelegate;

- (void)showTargetView:(UIView *)view;

@end

@interface CCAccountManageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLab;

@end
