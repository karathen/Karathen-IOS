//
//  KarathenFilterView.m
//  Karathen
//
//  Created by Karathen on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetFilterView.h"

@interface CCAssetFilterView ()

@property (nonatomic, strong) NSArray *filterArray;

@end

@implementation CCAssetFilterView

- (instancetype)init {
    if (self = [super initOptionView]) {
        [self customSet];
    }
    return self;
}

- (void)showTargetView:(UIView *)view {
    [self bindData];
    self.edgeInsets = UIEdgeInsetsMake(0, FitScale(10), 0, 0);
    [self showOffSetScale:.5 space:FitScale(3) viewWidth:FitScale(150) targetView:view direction:MLMOptionSelectViewBottom];
}

#pragma mark - bindData
- (void)bindData {
    switch (self.walletData.type) {
        case CCCoinTypeETH:
        {
            self.filterArray = @[Localized(@"Filter All"),CCAseet_ETH_ERC20,CCAseet_ETH_ERC721];
        }
            break;
        case CCCoinTypeNEO:
        {
            self.filterArray = @[Localized(@"Filter All"),CCAseet_NEO_NEO,CCAseet_NEO_GAS,CCAseet_NEO_Nep_5];
        }
            break;
        case CCCoinTypeONT:
        {
            self.filterArray = @[Localized(@"Filter All"),CCAseet_ONT_ONT,CCAseet_ONT_ONG];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 默认设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = NO;
    self.multiSelect = YES;
    self.optionType = MLMOptionSelectViewTypeArrow;

    [self registerClass:[CCAssetFilterCell class] forCellReuseIdentifier:@"CCAssetFilterCell"];
    [self registerClass:[CCAssetNoBalanceCell class] forCellReuseIdentifier:@"CCAssetNoBalanceCell"];
    
    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        if (indexPath.row < self.filterArray.count) {
            CCAssetFilterCell *cell = [self dequeueReusableCellWithIdentifier:@"CCAssetFilterCell"];
            NSString *filterType = self.filterArray[indexPath.row];
            cell.titleLab.text = filterType;
            if (indexPath.row == 0 && !self.walletData.wallet.filterType) {
                if (self.walletData.wallet.filterType) {
                    cell.titleLab.textColor = CC_BLACK_COLOR;
                } else {
                    cell.titleLab.textColor = CC_MAIN_COLOR;
                }
            } else {
                if ([filterType isEqualToString:self.walletData.wallet.filterType]) {
                    cell.titleLab.textColor = CC_MAIN_COLOR;
                } else {
                    cell.titleLab.textColor = CC_BLACK_COLOR;
                }
            }
            return cell;
        } else {
            CCAssetNoBalanceCell *cell = [self dequeueReusableCellWithIdentifier:@"CCAssetNoBalanceCell"];
            cell.titleLab.text = Localized(@"Hide the asset with no balance");
            [cell.switchBtn setOn:self.walletData.wallet.isHideNoBalance];
            return cell;
        }
    };
    
    self.optionCellHeight = ^float(NSIndexPath *indexPath) {
        @strongify(self)
        if (indexPath.row < self.filterArray.count) {
            return FitScale(30);
        } else {
            return FitScale(45);
        }
    };
    
    self.rowNumber = ^NSInteger{
        @strongify(self)
        return self.filterArray.count + 1;
    };
    
    self.selectedOption = ^(NSIndexPath *indexPath) {
        @strongify(self)
        if (indexPath.row < self.filterArray.count) {
            if (indexPath.row == 0) {
                [self.walletData changeFilterType:nil];
            } else {
                [self.walletData changeFilterType:self.filterArray[indexPath.row]];
            }
            [self dismiss];
        } else {
            BOOL isHiden = self.walletData.wallet.isHideNoBalance;
            [self.walletData changeHideNoBalance:!isHiden];
        }
        [self reloadData];
    };
}

@end


@implementation CCAssetFilterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(10));
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(14);
    }
    return _titleLab;
}

@end


@implementation CCAssetNoBalanceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = CC_GRAY_BACKCOLOR;
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
        
        [self.contentView addSubview:self.switchBtn];
        [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        self.switchBtn.layer.cornerRadius = self.switchBtn.cc_height;
        self.switchBtn.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(FitScale(5));
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(10));
            make.right.equalTo(self.switchBtn.mas_left);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(FitScale(-5));
        }];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(14);
        _titleLab.textColor = CC_BLACK_COLOR;
        _titleLab.numberOfLines = 2;
    }
    return _titleLab;
}


- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc] init];
        _switchBtn.onTintColor = CC_MAIN_COLOR;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        _switchBtn.backgroundColor = [UIColor blackColor];
        _switchBtn.transform = CGAffineTransformMakeScale(.6, .6);
        _switchBtn.userInteractionEnabled = NO;
    }
    return _switchBtn;
}

@end
