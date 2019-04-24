//
//  CCAccountManageView.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCAccountManageShowView.h"

@interface CCAccountManageShowView ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CCAccountManageShowView

- (instancetype)init {
    if (self = [super initOptionView]) {
        [self customSet];
    }
    return self;
}


- (void)showTargetView:(UIView *)view {
    [self bindData];
    self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    
    CGFloat viewwidth = FitScale(170);
    if ([[CCMultiLanguage manager].currentLanguage compareWithString:CCLanguageOfChinese]) {
        viewwidth = FitScale(130);
    }
    [self showOffSetScale:.5 space:FitScale(3) viewWidth:viewwidth targetView:view direction:MLMOptionSelectViewBottom];
}

#pragma mark - 默认设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = NO;
    self.optionType = MLMOptionSelectViewTypeArrow;
    self.maxLine = 10;
    [self registerClass:[CCAccountManageCell class] forCellReuseIdentifier:@"CCAccountManageCell"];
    
    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        CCAccountManageCell *cell = [self dequeueReusableCellWithIdentifier:@"CCAccountManageCell"];
        NSDictionary *dic = self.dataArray[indexPath.row];
        cell.titleLab.text = dic[@"title"];
        cell.iconView.image = [UIImage imageNamed:dic[@"icon"]];
        return cell;
    };
    
    self.optionCellHeight = ^float(NSIndexPath *indexPath) {
        return FitScale(45);
    };
    
    self.rowNumber = ^NSInteger{
        @strongify(self)
        return self.dataArray.count;
    };
    
    self.selectedOption = ^(NSIndexPath *indexPath) {
        @strongify(self)
        if (self.manageDelegate && [self.manageDelegate respondsToSelector:@selector(accountManageWithType:accountData:)]) {
            NSDictionary *dic = self.dataArray[indexPath.row];
            CCAccountManageType type = [dic[@"type"] integerValue];
            [self.manageDelegate accountManageWithType:type accountData:self.accountData];
        }
    };
}

- (void)bindData {
    NSMutableArray *dataArray = [NSMutableArray array];
    NSDictionary *coin = [self dataWithType:CCAccountManageTypeCoin];
    NSDictionary *name = [self dataWithType:CCAccountManageTypeName];
    NSDictionary *pwd = [self dataWithType:CCAccountManageTypePwd];
    NSDictionary *pwdInfp = [self dataWithType:CCAccountManageTypePwdInfo];
    NSDictionary *backUp = [self dataWithType:CCAccountManageTypeBackup];
    NSDictionary *delete = [self dataWithType:CCAccountManageTypeDelete];
    dataArray = [NSMutableArray arrayWithArray:@[
                                                 coin,
                                                 name,
                                                 pwd,
                                                 pwdInfp,
                                                 backUp,
                                                 delete
                                                 ]];
    if (self.accountData.coins.count <= 1) {
        [dataArray removeObject:coin];
    }
    if (self.accountData.account.importType == CCImportTypeHardware) {
        [dataArray removeObject:pwdInfp];
    }
    if (self.accountData.account.importType != CCImportTypeMnemonic && self.accountData.account.importType != CCImportTypeSeed) {
        [dataArray removeObject:backUp];
    }
    
    self.dataArray = dataArray;
}

#pragma mark - data
- (NSDictionary *)dataWithType:(CCAccountManageType)type {
    switch (type) {
        case CCAccountManageTypeName:
        {
            return @{
                     @"icon":@"cc_wallet_manage_name",
                     @"title":Localized(@"Change name"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAccountManageTypePwd:
        {
            return @{
                     @"icon":@"cc_wallet_manage_pwd",
                     @"title":Localized(@"Reset password"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAccountManageTypePwdInfo:
        {
            return @{
                     @"icon":@"cc_wallet_manage_pwdInfo",
                     @"title":Localized(@"Password prompt"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAccountManageTypeCoin:
        {
            return @{
                     @"icon":@"cc_wallet_manage_coin",
                     @"title":Localized(@"Multi-chain management"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAccountManageTypeBackup:
        {
            return @{
                     @"icon":@"cc_wallet_manage_backup",
                     @"title":Localized(@"Backup wallet"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAccountManageTypeDelete:
        {
            return @{
                     @"icon":@"cc_wallet_manage_delete",
                     @"title":Localized(@"Delete wallet"),
                     @"type":@(type)
                     };
        }
            break;
        default:
            break;
    }
    return nil;
}


@end

@implementation CCAccountManageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(15));
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(FitScale(10));
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(10));
        }];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(FitScale(14));
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

@end
