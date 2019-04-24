//
//  CCBottomLineTableViewCell.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/11.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBottomLineTableViewCell.h"

@interface CCBottomLineTableViewCell ()

@property (nonatomic, strong) UIImageView *lineImgView;

@end


@implementation CCBottomLineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.lineImgView];
    [self.lineImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(14));
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(10));
    }];
}

#pragma mark - get
- (UIImageView *)lineImgView {
    if (!_lineImgView) {
        _lineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_line"]];
    }
    return _lineImgView;
}

@end
