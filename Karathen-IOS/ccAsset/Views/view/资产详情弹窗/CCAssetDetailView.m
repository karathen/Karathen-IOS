//
//  CCAssetDetailView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAssetDetailView.h"

@implementation CCAssetDetailView

- (instancetype)init {
    if (self = [super initOptionView]) {
        [self customSet];
    }
    return self;
}

- (void)showTargetView:(UIView *)view {
    UIButton *btn = (UIButton *)view;
    self.edgeInsets = UIEdgeInsetsMake(0, FitScale(10), 0, FitScale(10));
    [self showOffSetScale:.5 space:FitScale(3) viewWidth:SCREEN_WIDTH-FitScale(10) targetView:btn.imageView direction:MLMOptionSelectViewBottom];
}

#pragma mark - 默认设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = NO;
    self.multiSelect = YES;
    self.optionType = MLMOptionSelectViewTypeArrow;
    
    [self registerClass:[CCAssetDetailTypeCell class] forCellReuseIdentifier:@"CCAssetDetailTypeCell"];
    [self registerClass:[CCAssetDetailBottomCell class] forCellReuseIdentifier:@"CCAssetDetailBottomCell"];
    
    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        NSInteger row = indexPath.row;
        if (row == 3) {
            CCAssetDetailBottomCell *cell = [self dequeueReusableCellWithIdentifier:@"CCAssetDetailBottomCell"];
            cell.titleLab.text = Localized(@"Contract address");
            cell.tokenLab.text = self.asset.tokenAddress;
            cell.descLab.text = Localized(@"Attention:this address is not the address of receiving asset");
            return cell;
        } else {
            CCAssetDetailTypeCell *cell = [self dequeueReusableCellWithIdentifier:@"CCAssetDetailTypeCell"];
            NSString *text;
            if (row == 0) {
                text = [NSString stringWithFormat:@"%@：%@",Localized(@"Asset symbol"),self.asset.tokenSynbol];
            } else if (row == 1) {
                text = [NSString stringWithFormat:@"%@：%@",Localized(@"Asset name"),self.asset.tokenName];
            } else {
                text = [NSString stringWithFormat:@"%@：%@",Localized(@"Asset type"),self.asset.tokenType?:self.asset.tokenSynbol];
            }
            cell.titleLab.text = text;
            return cell;
        }
    };
    
    self.optionCellHeight = ^float(NSIndexPath *indexPath) {
        if (indexPath.row == 3) {
            return FitScale(95);
        } else {
            return FitScale(50);
        }
    };
    
    self.selectedOption = ^(NSIndexPath *indexPath) {
        @strongify(self)
        if (indexPath.row == 3) {
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.string = self.asset.tokenAddress;
            [MBProgressHUD showMessage:Localized(@"Copy Success") inView:self];
        } else {
            [self dismiss];
        }
    };
    
    self.rowNumber = ^NSInteger{
        return 4;
    };
}


@end


@implementation CCAssetDetailTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.contentView.mas_left).offset(FitScale(10));
            make.center.equalTo(self.contentView);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = CC_GRAY_BACKCOLOR;
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(10));
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BLACK_COLOR;
        _titleLab.font = MediumFont(FitScale(13));
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

@end

@implementation CCAssetDetailBottomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.contentView.mas_left).offset(FitScale(10));
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.contentView.mas_top).offset(FitScale(10));
        }];
        
        [self.contentView addSubview:self.tokenLab];
        [self.tokenLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.contentView.mas_left).offset(FitScale(10));
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.titleLab.mas_bottom).offset(FitScale(10));
        }];
        
        [self.contentView addSubview:self.descLab];
        [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.contentView.mas_left).offset(FitScale(10));
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.tokenLab.mas_bottom).offset(FitScale(10));
        }];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = CC_BLACK_COLOR;
        _titleLab.font = MediumFont(FitScale(13));
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UILabel *)tokenLab {
    if (!_tokenLab) {
        _tokenLab = [[UILabel alloc] init];
        _tokenLab.textColor = CC_GRAY_TEXTCOLOR;
        _tokenLab.font = MediumFont(FitScale(12));
        _tokenLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _tokenLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tokenLab;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_BTN_ENABLE_COLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.numberOfLines = 0;
        _descLab.textAlignment = NSTextAlignmentCenter;
    }
    return _descLab;
}

@end
