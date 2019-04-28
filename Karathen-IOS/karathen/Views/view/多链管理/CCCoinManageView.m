//
//  CCCoinManageView.m
//  Karathen
//
//  Created by Karathen on 2018/10/19.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoinManageView.h"
#import "CCCoreData.h"

@interface CCCoinManageView () <UITableViewDelegate, UITableViewDataSource,CCCoinManageCellDelegate>

@property (nonatomic, weak) CCAccountData *account;

@property (nonatomic, strong) CCCoinManageHead *topView;
@property (nonatomic, strong) UIButton *confirmBtn;

//页面展示的信息
@property (nonatomic, strong) NSMutableArray *coinTypeArray;


@end

@implementation CCCoinManageView

- (instancetype)initWithAccount:(CCAccountData *)account {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.delegate = self;
        self.dataSource = self;
        self.account = account;
        [self registerClassCells:@[[CCCoinManageCell class]]];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        self.tableHeaderView = self.topView;
        
        self.tableFooterView = [self bottomView];
    }
    return self;
}

- (UIView *)bottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FitScale(100))];
    [bottomView addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView.mas_left).offset(FitScale(40));
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(bottomView.mas_top).offset(FitScale(30));
        make.centerX.equalTo(bottomView.mas_centerX);
    }];
    @weakify(self)
    [self.confirmBtn cc_tapHandle:^{
        @strongify(self)
        [self confirmAction];
    }];
    return bottomView;
}

#pragma mark - 长按手势
- (void)moveCellAction:(UILongPressGestureRecognizer *)longPress {
    //获取长按的点
    CGPoint location = [longPress locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    
    UIGestureRecognizerState state = longPress.state;
    static UIView *snapView = nil;
    static NSIndexPath *sourceIndex = nil;
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            if (indexPath) {
                sourceIndex = indexPath;
                UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
                snapView = [cell snapshotViewAfterScreenUpdates:NO];
                
                __block CGPoint center = cell.center;
                snapView.center = center;
                snapView.alpha = 0.0;
                [self addSubview:snapView];
                
                [UIView animateWithDuration:0.1 animations:^{
                    center.y = location.y;
                    snapView.center = center;
                    snapView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapView.alpha = 0.5;
                    
                    cell.alpha = 0.0;
                }];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = snapView.center;
            center.y = location.y;
            snapView.center = center;
            
            UITableViewCell *cell = [self cellForRowAtIndexPath:sourceIndex];
            cell.alpha = 0.0;
            
            if (indexPath && ![indexPath isEqual:sourceIndex]) {
                
                [self.coinTypeArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndex.row];
                [self moveRowAtIndexPath:sourceIndex toIndexPath:indexPath];
                
                sourceIndex = indexPath;
            }
        }
            break;
        default:
        {
            UITableViewCell *cell = [self cellForRowAtIndexPath:sourceIndex];
            [UIView animateWithDuration:0.25 animations:^{
                snapView.center = cell.center;
                snapView.transform = CGAffineTransformIdentity;
                snapView.alpha = 0.0;
                
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                [snapView removeFromSuperview];
                snapView = nil;
            }];
            sourceIndex = nil;
        }
            break;
    }
}


#pragma mark - confirmAction
- (void)confirmAction {
    for (int i = 0; i < self.coinTypeArray.count; i ++) {
        CCCoinManageModel *model = self.coinTypeArray[i];
        CCCoinData *coinData = [self.account coinDataWithCoinType:model.coinType];
        coinData.coin.sortID = i;
        coinData.coin.isHidden = model.isHidden;
    }
    
    [[CCCoreData coreData] saveDataCompletion:nil];

    if ([self.manageDelegate respondsToSelector:@selector(confirmManageView:)]) {
        [self.manageDelegate confirmManageView:self];
    }
    
    [self.account changeCoins];
    
    [CCNotificationCenter postCoinManage];
}

#pragma mark - 是否只剩下一个打开的
- (NSInteger)noHiddenCount {
    NSInteger noHiddenCount = 0;
    for (CCCoinManageModel *model in self.coinTypeArray) {
        BOOL hidden = model.isHidden;
        if (!hidden) {
            noHiddenCount += 1;
        }
    }
    return noHiddenCount;
}

#pragma mark - CCCoinManageCellDelegate
- (void)changeHiddenWithModel:(CCCoinManageModel *)model {
    NSInteger noHiddenCount = [self noHiddenCount];
    if (noHiddenCount == 1 && !model.isHidden) {
        [MBProgressHUD showMessage:Localized(@"At least display one chain")];
    } else {
        model.isHidden = !model.isHidden;
    }
    [self reloadData];
}


#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coinTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCCoinManageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCCoinManageCell"];
    CCCoinManageModel *model = self.coinTypeArray[indexPath.row];
    cell.delegate = self;
    [cell bindCellWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FitScale(60);
}


#pragma mark - get
- (CCCoinManageHead *)topView {
    if (!_topView) {
        _topView = [[CCCoinManageHead alloc] init];
    }
    return _topView;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.backgroundColor = CC_MAIN_COLOR;
        _confirmBtn.layer.cornerRadius = FitScale(5);
        _confirmBtn.layer.masksToBounds = YES;
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = MediumFont(FitScale(14));
        [_confirmBtn setTitle:Localized(@"Confirm") forState:UIControlStateNormal];
    }
    return _confirmBtn;
}

- (NSMutableArray *)coinTypeArray {
    if (!_coinTypeArray) {
        _coinTypeArray = [NSMutableArray array];
        for (CCCoinData *coinData in self.account.coins) {
            CCCoinManageModel *model = [[CCCoinManageModel alloc] init];
            model.isHidden = coinData.coin.isHidden;
            model.coinType = coinData.coin.coinType;
            [_coinTypeArray addObject:model];
        }
    }
    return _coinTypeArray;
}



@end

@interface CCCoinManageCell ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *detailLab;

@property (nonatomic, strong) UISwitch *switchBtn;
@property (nonatomic, weak) CCCoinManageModel *model;
@property (nonatomic, strong) UILongPressGestureRecognizer *moveGesture;

@end

@implementation CCCoinManageCell


- (void)bindCellWithModel:(CCCoinManageModel *)model {
    self.model = model;
    [self.iconImgView setImage:[UIImage imageNamed:[CCDataManager coinIconWithType:model.coinType]]];
    self.nameLab.text = [CCDataManager coinKeyWithType:model.coinType];
    self.detailLab.text = [CCDataManager coinNameWithType:model.coinType];
    self.switchBtn.on = !model.isHidden;
}

- (void)moveCellAction:(UILongPressGestureRecognizer *)longPress {
    if ([self.delegate respondsToSelector:@selector(moveCellAction:)]) {
        [self.delegate moveCellAction:longPress];
    }
}


#pragma mark - super method
- (void)createView {
    [super createView];

    [self.contentView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(FitScale(14));
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(FitScale(18), FitScale(18)));
    }];
    
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(15));
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-FitScale(3));
    }];
    
    [self.contentView addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_left);
        make.top.equalTo(self.contentView.mas_centerY).offset(FitScale(3));
    }];
    
    [self addSubview:self.switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(FitScale(-10));
    }];
    self.switchBtn.layer.cornerRadius = self.switchBtn.cc_height/2.0;
    self.switchBtn.layer.masksToBounds = YES;
    self.switchBtn.transform = CGAffineTransformMakeScale(.6, .6);

    [self.switchBtn addTarget:self action:@selector(changeHidden:) forControlEvents:UIControlEventValueChanged];
    
    [self.contentView addGestureRecognizer:self.moveGesture];
}

#pragma mark - switch
- (void)changeHidden:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(changeHiddenWithModel:)]) {
        [self.delegate changeHiddenWithModel:self.model];
    }
}


#pragma mark - get
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImgView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = CC_BLACK_COLOR;
        _nameLab.font = MediumFont(FitScale(14));
    }
    return _nameLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = RGB(0x90939b);
        _detailLab.font = MediumFont(FitScale(11));
    }
    return _detailLab;
}

- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc] init];
        _switchBtn.onTintColor = CC_MAIN_COLOR;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        _switchBtn.backgroundColor = [UIColor blackColor];
    }
    return _switchBtn;
}

- (UILongPressGestureRecognizer *)moveGesture {
    if (!_moveGesture) {
        _moveGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCellAction:)];
        _moveGesture.minimumPressDuration = 0.0;
    }
    return _moveGesture;
}


@end

@interface CCCoinManageHead ()

@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UIImageView *lineImgView;

@end


@implementation CCCoinManageHead

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.detailLab];
        [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(FitScale(14));
            make.top.equalTo(self.mas_top).offset(FitScale(12));
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(FitScale(-10));
        }];
        
        [self addSubview:self.lineImgView];
        [self.lineImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - get
- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = RGB(0x90939b);
        _detailLab.font = MediumFont(FitScale(10));
        _detailLab.text = Localized(@"Coin Manage Title");
        _detailLab.numberOfLines = 0;
    }
    return _detailLab;
}

- (UIImageView *)lineImgView {
    if (!_lineImgView) {
        _lineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_cell_line"]];
    }
    return _lineImgView;
}

@end

@implementation CCCoinManageModel


@end
