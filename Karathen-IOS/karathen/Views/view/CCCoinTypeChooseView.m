//
//  CCCoinTypeChooseView.m
//  Karathen
//
//  Created by Karathen on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoinTypeChooseView.h"



@implementation CCCoinTypeChooseView

- (instancetype)initWithImportType:(CCImportType)importType chooseType:(CCCoinType)chooseType {
    if (self = [self initOptionView]) {
        self.importType = importType;
        self.chooseType = chooseType;
        
        [self customSet];
    }
    return self;
}


- (void)showTargetView:(UIView *)view space:(CGFloat)space {
    self.edgeInsets = UIEdgeInsetsMake(STATUS_AND_NAVIGATION_HEIGHT, 0, TAB_BAR_HEIGHT, FitScale(10));
    [self showOffSetScale:.5 space:space viewWidth:FitScale(120) targetView:view direction:MLMOptionSelectViewBottom];
}

- (NSArray *)coins {
    switch (self.importType) {
        case CCImportTypeKeystore:
        {
            return @[@(CCCoinTypeETH)];
        }
            break;
        case CCImportTypePrivateKey:
        {
            return @[
                     @(CCCoinTypeETH),
                     @(CCCoinTypeNEO),
                     @(CCCoinTypeONT)
                     ];
        }
            break;
        case CCImportTypeWIF:
        {
            return @[
                     @(CCCoinTypeNEO),
                     @(CCCoinTypeONT)
                     ];
        }
            break;
        default:
            break;
    }
    return nil;
}


#pragma mark - 设置
- (void)customSet {
    self.canEdit = NO;
    self.vhShow = YES;
    self.multiSelect = NO;
    self.maxLine = 6;
    self.cornerRadius = FitScale(5);
    self.coverColor = [UIColor colorWithWhite:0 alpha:.3];
    self.optionType = MLMOptionSelectViewTypeArrow;
    
    [self registerClass:[CCCoinTypeChooseCell class] forCellReuseIdentifier:@"CCCoinTypeChooseCell"];
    
    @weakify(self)
    self.cell = ^UITableViewCell *(NSIndexPath *indexPath) {
        @strongify(self)
        CCCoinType coinType = [[self coins][indexPath.row] integerValue];
        CCCoinTypeChooseCell *cell = [self dequeueReusableCellWithIdentifier:@"CCCoinTypeChooseCell"];
        [cell bindCellWithCoinType:coinType selected:self.chooseType==coinType];
        return cell;
    };
    
    self.optionCellHeight = ^float(NSIndexPath *indexPath) {
        return FitScale(40);
    };
    
    self.selectedOption = ^(NSIndexPath *indexPath) {
        @strongify(self)
        CCCoinType coinType = [[self coins][indexPath.row] integerValue];
        self.chooseType = coinType;
        if ([self.chooseDelegate respondsToSelector:@selector(chooseView:coinType:)]) {
            [self.chooseDelegate chooseView:self coinType:self.chooseType];
        }

    };
    
    self.rowNumber = ^NSInteger{
        @strongify(self)
        return [self coins].count;
    };
}


@end

@interface CCCoinTypeChooseCell ()

@property (nonatomic, strong) UILabel *contentLab;

@end

@implementation CCCoinTypeChooseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.contentLab];
        [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)bindCellWithCoinType:(CCCoinType)coinType selected:(BOOL)selected {
    self.contentLab.text = [CCDataManager coinKeyWithType:coinType];
    if (selected) {
        self.contentLab.textColor = CC_BTN_ENABLE_COLOR;
    } else {
        self.contentLab.textColor = CC_BLACK_COLOR;
    }
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textAlignment = NSTextAlignmentCenter;
        _contentLab.font = MediumFont(FitScale(14));
        _contentLab.textColor = CC_BLACK_COLOR;
    }
    return _contentLab;
}

@end
