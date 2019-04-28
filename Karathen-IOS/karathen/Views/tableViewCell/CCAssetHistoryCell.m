//
//  KarathenHistoryCell.m
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetHistoryCell.h"
#import "CCTradeRecordModel.h"
#import "NSDate+Category.h"
#import "CCTradeRecord+CoreDataClass.h"

@interface CCAssetHistoryCell ()

@property (nonatomic, strong) UIImageView *typeImgView;
@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UILabel *statusLab;

@end

@implementation CCAssetHistoryCell

- (void)bindCellWithModel:(CCTradeRecordModel *)model walletData:(CCWalletData *)walletData asset:(CCAsset *)asset value:(NSString *)value {
    BOOL turnOut = [model.addressFrom compareWithString:walletData.address];
    
    [self.typeImgView setImage:[UIImage imageNamed:turnOut?@"cc_asset_history_out":@"cc_asset_history_in"]];
    self.descLab.text = [NSString stringWithFormat:@"%@-%@",Localized(@"Transfer"),model.txId];
    if ([asset.tokenType compareWithString:CCAseet_ETH_ERC721]) {
        self.priceLab.text = [NSString stringWithFormat:@"#%@",value];
    } else {
        self.priceLab.text = [NSString stringWithFormat:@"%@%@%@",turnOut?@"-":@"+",value,asset.tokenSynbol];
    }
    
    self.timeLab.text = model.blockTimeString;
    
    self.statusLab.textColor = CC_BTN_ENABLE_COLOR;
    if (walletData.type == CCCoinTypeETH) {
        if (model.txReceiptStatus == 0) {
            self.statusLab.text = @"0/12";
        } else if (model.txReceiptStatus == -1) {
            self.statusLab.textColor = [UIColor redColor];
            self.statusLab.text = Localized(@"Fail");
        } else if (model.txReceiptStatus == 1) {
            NSInteger nowBlockHeight = [[CCDataManager dataManager] blockHeightWithType:walletData.type];
            NSInteger tradeBlock = model.blockHeight.integerValue;
            if (tradeBlock == 0 || nowBlockHeight == 0) {
                self.statusLab.text = @"0/12";
            } else {
                NSInteger result = nowBlockHeight - tradeBlock + 1;
                if (result >= 12) {
                    self.statusLab.text = Localized(@"Success");
                } else {
                    self.statusLab.text = [NSString stringWithFormat:@"%@/12",@(MIN(12, MAX(0, result)))];
                }
            }
        }
    } else if (walletData.type == CCCoinTypeNEO) {
        if ([CCWalletData isNEOOrNEOGas:asset.tokenAddress]) {
            if (model.blockHeight.integerValue > 0) {
                self.statusLab.text = Localized(@"Success");
            } else {
                self.statusLab.text = @"0/1";
            }
        } else {
            if (model.txReceiptStatus == 0) {
                self.statusLab.text = @"0/1";
            } else if (model.txReceiptStatus == -1) {
                self.statusLab.textColor = [UIColor redColor];
                self.statusLab.text = Localized(@"Fail");
            } else if (model.txReceiptStatus == 1) {
                self.statusLab.text = Localized(@"Success");
            }
        }
    } else {
        if (model.txReceiptStatus == 0) {
            self.statusLab.text = @"0/1";
        } else if (model.txReceiptStatus == -1) {
            self.statusLab.textColor = [UIColor redColor];
            self.statusLab.text = Localized(@"Fail");
        } else if (model.txReceiptStatus == 1) {
            self.statusLab.text = Localized(@"Success");
        }
    }
}


#pragma mark - super method
- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.typeImgView];
    [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(15));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeImgView.mas_right).offset(FitScale(22));
        make.bottom.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.priceLab];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.descLab.mas_bottom);
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(18)); make.left.greaterThanOrEqualTo(self.descLab.mas_right).offset(FitScale(10));

    }];
    
    [self.priceLab
     setContentCompressionResistancePriority:UILayoutPriorityRequired
     forAxis:UILayoutConstraintAxisHorizontal
     ];
    [self.contentView addSubview:self.timeLab];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.descLab.mas_left);
        make.top.equalTo(self.descLab.mas_bottom).offset(FitScale(8));
    }];
    
    [self.contentView addSubview:self.statusLab];
    [self.statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.priceLab.mas_right);
        make.centerY.equalTo(self.timeLab.mas_centerY);
        make.left.greaterThanOrEqualTo(self.timeLab.mas_right).offset(FitScale(10));
    }];
    
    
    [self.statusLab
     setContentCompressionResistancePriority:UILayoutPriorityRequired
     forAxis:UILayoutConstraintAxisHorizontal
     ];
}

#pragma mark - get
- (UIImageView *)typeImgView {
    if (!_typeImgView) {
        _typeImgView = [[UIImageView alloc] init];
    }
    return _typeImgView;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_BLACK_COLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _descLab;
}

- (UILabel *)priceLab {
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        _priceLab.textColor = CC_BLACK_COLOR;
        _priceLab.font = MediumFont(FitScale(12));
    }
    return _priceLab;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.textColor = RGB(0xC6C5CB);
        _timeLab.font = MediumFont(FitScale(11));
        _timeLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _timeLab;
}

- (UILabel *)statusLab {
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.font = MediumFont(FitScale(11));
    }
    return _statusLab;
}

@end
