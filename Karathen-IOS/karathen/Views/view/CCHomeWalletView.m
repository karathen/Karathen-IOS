//
//  CCHomeWalletView.m
//  Karathen
//
//  Created by Karathen on 2018/11/28.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCHomeWalletView.h"
#import "MLMSegmentHead.h"
#import "CCGuideView.h"

@interface CCHomeWalletView () <CCGuideViewDelegate>

@property (nonatomic, strong) MLMSegmentHead *segmentHead;
@property (nonatomic, strong) CCGuideView *guideView;

@property (nonatomic, strong) NSArray *sourceArray;

@end

@implementation CCHomeWalletView

- (instancetype)init {
    if (self = [super init]) {
        CCHomeWalletTypeModel *model = self.sourceArray.firstObject;
        self.walletType = model.walletType;
        [self createView];
    }
    return self;
}

- (void)changeToIndex:(NSInteger)index {
    CCHomeWalletTypeModel *model = self.sourceArray[index];
    self.walletType = model.walletType;
    if ([self.delegate respondsToSelector:@selector(walletTypeChangeWithView:)]) {
        [self.delegate walletTypeChangeWithView:self];
    }
}

#pragma mark - createView
- (void)createView {
    CGFloat topHeight = 0;
    if (self.sourceArray.count > 1) {
        [self addSubview:self.segmentHead];
        topHeight = self.segmentHead.cc_height;
    }

    [self addSubview:self.guideView];
    [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(topHeight);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    @weakify(self)
    self.segmentHead.selectedIndex = ^(NSInteger index) {
        @strongify(self)
        [self.guideView scrollToIndex:index animation:YES];
        [self changeToIndex:index];
    };
}

#pragma mark - delegate
- (void)scrollToIndex:(NSInteger)index {
    [self changeToIndex:index];
    [self.segmentHead setSelectIndex:index];
    [self.segmentHead animationEnd];
}

- (void)scrollScale:(CGFloat)scale {
    [self.segmentHead changePointScale:scale];
}


#pragma mark - get
- (MLMSegmentHead *)segmentHead {
    if (!_segmentHead) {
        NSMutableArray *titles = [NSMutableArray array];
        for (CCHomeWalletTypeModel *model in self.sourceArray) {
            [titles addObject:model.title];
        }
        _segmentHead = [[MLMSegmentHead alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FitScale(45)) titles:titles headStyle:SegmentHeadStyleLine layoutStyle:MLMSegmentLayoutDefault];
        _segmentHead.selectColor = CC_MAIN_COLOR;
        _segmentHead.deSelectColor = CC_BLACK_COLOR;
        _segmentHead.fontSize = FitScale(15);
        _segmentHead.bottomLineHeight = 0;
        _segmentHead.lineHeight = FitScale(2);
        _segmentHead.lineColor = CC_MAIN_COLOR;
        [_segmentHead defaultAndCreateView];
    }
    return _segmentHead;
}

- (CCGuideView *)guideView {
    if (!_guideView) {
        NSMutableArray *icons = [NSMutableArray array];
        NSMutableArray *contents = [NSMutableArray array];
        for (CCHomeWalletTypeModel *model in self.sourceArray) {
            [icons addObject:model.icon];
            [contents addObject:model.content];
        }
        _guideView = [[CCGuideView alloc] initWithIcons:icons contents:contents];
        _guideView.delegate = self;
    }
    return _guideView;
}

- (NSArray *)sourceArray {
    if (!_sourceArray) {
        CCHomeWalletTypeModel *phone = [[CCHomeWalletTypeModel alloc] initWithWalletType:CCWalletTypePhone];
        CCHomeWalletTypeModel *hardware = [[CCHomeWalletTypeModel alloc] initWithWalletType:CCWalletTypeHardware];
        
        _sourceArray = @[
                         phone,
                         hardware
                         ];
    }
    return _sourceArray;
}

@end


@implementation CCHomeWalletTypeModel

- (instancetype)initWithWalletType:(CCWalletType)walletType {
    if (self = [super init]) {
        self.walletType = walletType;
        switch (walletType) {
            case CCWalletTypePhone:
            {
                self.title = Localized(@"HD wallet");
                self.icon = @"cc_guide_2";
                self.content = Localized(@"Guide Content 2");
            }
                break;
            case CCWalletTypeHardware:
            {
                self.title = Localized(@"Hardware wallet");
                self.icon = @"cc_guide_3";
                self.content = Localized(@"Guide Content 3");
            }
                break;
            default:
                break;
        }
    }
    return self;
}

@end
