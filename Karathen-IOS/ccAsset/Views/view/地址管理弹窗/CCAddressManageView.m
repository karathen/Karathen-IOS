//
//  CCAddressManageView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/5.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAddressManageView.h"

@interface CCAddressManageView ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CCAddressManageView

- (instancetype)init {
    if (self = [super initOptionView]) {
        [self customSet];
    }
    return self;
}

- (void)showTargetView:(UIView *)view {
    [self bindData];
    self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    
    CGFloat viewwidth = FitScale(180);
    if ([[CCMultiLanguage manager].currentLanguage compareWithString:CCLanguageOfChinese]) {
        viewwidth = FitScale(150);
    }
    [self showOffSetScale:.5 space:FitScale(3) viewWidth:viewwidth targetView:view direction:MLMOptionSelectViewBottom];
}

#pragma mark - 默认设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = NO;
    self.optionType = MLMOptionSelectViewTypeArrow;
    self.maxLine = 10;
    [self registerClass:[CCAddressManageCell class] forCellReuseIdentifier:@"CCAddressManageCell"];
    
    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        CCAddressManageCell *cell = [self dequeueReusableCellWithIdentifier:@"CCAddressManageCell"];
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
        if (self.manageDelegate && [self.manageDelegate respondsToSelector:@selector(addressManageWithType:walletData:)]) {
            NSDictionary *dic = self.dataArray[indexPath.row];
            CCAddressManageType type = [dic[@"type"] integerValue];
            [self.manageDelegate addressManageWithType:type walletData:self.walletData];
        }
    };
}

- (void)bindData {
    NSMutableArray *dataArray = [NSMutableArray array];
    NSDictionary *keystore = [self dataWithType:CCAddressManageKeystore];
    NSDictionary *private = [self dataWithType:CCAddressManagePrivateKey];
    NSDictionary *wif = [self dataWithType:CCAddressManageWIF];
    NSDictionary *name = [self dataWithType:CCAddressManageName];
    NSDictionary *internet = [self dataWithType:CCAddressManageInternet];
    NSDictionary *gas = [self dataWithType:CCAddressManageClaimGas];
    dataArray = [NSMutableArray arrayWithArray:@[
                                                 keystore,
                                                 private,
                                                 wif,
                                                 name,
                                                 internet,
                                                 gas
                                                 ]];
    CCAccountData *accountData = [[CCDataManager dataManager] accountWithAccountID:self.walletData.wallet.accountID];
    if (accountData.account.walletType == CCWalletTypeHardware) {
        [dataArray removeObject:keystore];
        [dataArray removeObject:private];
        [dataArray removeObject:wif];
        [dataArray removeObject:gas];
    } else {
        if (self.walletData.type == CCCoinTypeETH) {
            [dataArray removeObject:wif];
            [dataArray removeObject:gas];
        } else {
            [dataArray removeObject:keystore];
        }
    }

    self.dataArray = dataArray;
}

#pragma mark - data
- (NSDictionary *)dataWithType:(CCAddressManageType)type {
    switch (type) {
        case CCAddressManageKeystore:
        {
            return @{
                     @"icon":@"cc_address_manage_mnemonic",
                     @"title":Localized(@"Export keystore"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAddressManagePrivateKey:
        {
            return @{
                     @"icon":@"cc_address_manage_key",
                     @"title":Localized(@"Export Private Key"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAddressManageWIF:
        {
            return @{
                     @"icon":@"cc_address_manage_wif",
                     @"title":Localized(@"Export WIF"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAddressManageInternet:
        {
            return @{
                     @"icon":@"cc_address_manage_internet",
                     @"title":Localized(@"Enter the explorer"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAddressManageDelete:
        {
            return @{
                     @"icon":@"cc_address_manage_delete",
                     @"title":Localized(@"Delete address"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAddressManageName:
        {
            return @{
                     @"icon":@"cc_address_manage_name",
                     @"title":Localized(@"Change name"),
                     @"type":@(type)
                     };
        }
            break;
        case CCAddressManageClaimGas:
        {
            NSString *symbol = [self.walletData claimSymbol];
            return @{
                     @"icon":@"cc_address_manage_claim",
                     @"title":[NSString stringWithFormat:Localized(@"Claim Symbol"),symbol],
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


@implementation CCAddressManageCell

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
