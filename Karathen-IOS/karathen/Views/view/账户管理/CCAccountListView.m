//
//  CCAccountListView.m
//  Karathen
//
//  Created by Karathen on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCAccountListView.h"
#import "CCAccountManageShowView.h"

@interface CCAccountListView ()
<
UITableViewDelegate,
UITableViewDataSource,
CCAccountListCellDelegate,
CCAccountManageViewDelegate
>

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) CCAccountManageShowView *accountManageView;

@end

@implementation CCAccountListView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.delegate = self;
        self.dataSource = self;
        [self registerClassCells:@[[CCAccountListCell class]]];
        [self registerClass:[CCAccountListFootView class] forHeaderFooterViewReuseIdentifier:@"CCAccountListFootView"];
        [self addNotify];
    }
    return self;
}

- (UIView *)footView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FitScale(120))];

    [view addSubview:self.addBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top).offset(FitScale(40));
        make.left.equalTo(view.mas_left).offset(FitScale(40));
        make.centerX.equalTo(view);
        make.height.mas_equalTo(FitScale(45));
    }];
 
    @weakify(self)
    [self.addBtn cc_tapHandle:^{
        @strongify(self)
        if ([self.accountDelegate respondsToSelector:@selector(addNewWallet)]) {
            [self.accountDelegate addNewWallet];
        }
    }];
    
    return view;
}

#pragma mark - addNotify
- (void)addNotify {
    @weakify(self)
    [CCNotificationCenter receiveAccountNameChangeObserver:self completion:^(NSString *accountID) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
    
    [CCNotificationCenter receiveAccountChangeObserver:self completion:^(BOOL add, NSString *accountID) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
    
    [CCNotificationCenter receiveActiveAccountChangeObserver:self completion:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
    
    [CCNotificationCenter receiveAccountBackUpObserver:self completion:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
}


#pragma mark - delegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CCDataManager dataManager].accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCAccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCAccountListCell"];
    cell.delegate = self;
    [self bindCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)bindCell:(CCAccountListCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    CCAccountData *account = [CCDataManager dataManager].accounts[indexPath.row];
    [cell bindCellWithAccount:account];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    return [tableView fd_heightForCellWithIdentifier:@"CCAccountListCell" configuration:^(CCAccountListCell *cell) {
        @strongify(self)
        [self bindCell:cell withIndexPath:indexPath];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CCAccountListFootView *footView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CCAccountListFootView"];
    @weakify(self)
    [footView.addBtn cc_tapHandle:^{
        @strongify(self)
        if ([self.accountDelegate respondsToSelector:@selector(addNewWallet)]) {
            [self.accountDelegate addNewWallet];
        }
    }];
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FitScale(70);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .000001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCAccountData *account = [CCDataManager dataManager].accounts[indexPath.row];
    [[CCDataManager dataManager] changeActiveAccount:account];
}

#pragma mark - CCAccountListCellDelegate
- (void)moreAccountCell:(CCAccountListCell *)cell account:(CCAccountData *)account targetView:(UIView *)targetView {
    self.accountManageView.accountData = account;
    [self.accountManageView showTargetView:targetView];
}

#pragma mark - CCAccountManageViewDelegate
- (void)accountManageWithType:(CCAccountManageType)type accountData:(CCAccountData *)accountData {
    switch (type) {
        case CCAccountManageTypeName:
        {
            if ([self.accountDelegate respondsToSelector:@selector(changeWalletNameWithAccount:)]) {
                [self.accountDelegate changeWalletNameWithAccount:accountData];
            }
        }
            break;
        case CCAccountManageTypePwd:
        {
            if ([self.accountDelegate respondsToSelector:@selector(changeWalletPwdWithAccount:)]) {
                [self.accountDelegate changeWalletPwdWithAccount:accountData];
            }
        }
            break;
        case CCAccountManageTypePwdInfo:
        {
            if ([self.accountDelegate respondsToSelector:@selector(showWalletPwdInfoWithAccount:)]) {
                [self.accountDelegate showWalletPwdInfoWithAccount:accountData];
            }
        }
            break;
        case CCAccountManageTypeCoin:
        {
            if ([self.accountDelegate respondsToSelector:@selector(walletCoinManagerWithAccount:)]) {
                [self.accountDelegate walletCoinManagerWithAccount:accountData];
            }
        }
            break;
        case CCAccountManageTypeBackup:
        {
            if ([self.accountDelegate respondsToSelector:@selector(walletBackUpWithAccount:)]) {
                [self.accountDelegate walletBackUpWithAccount:accountData];
            }
        }
            break;
        case CCAccountManageTypeDelete:
        {
            if ([self.accountDelegate respondsToSelector:@selector(deleteWalletWithAccount:)]) {
                [self.accountDelegate deleteWalletWithAccount:accountData];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - get
- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _addBtn.layer.cornerRadius = FitScale(5);
        _addBtn.layer.masksToBounds = YES;
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = MediumFont(FitScale(14));
        [_addBtn setTitle:Localized(@"Add wallet") forState:UIControlStateNormal];
    }
    return _addBtn;
}

- (CCAccountManageShowView *)accountManageView {
    if (!_accountManageView) {
        _accountManageView = [[CCAccountManageShowView alloc] init];
        _accountManageView.manageDelegate = self;
    }
    return _accountManageView;
}

@end

@interface CCAccountListCell ()

@property (nonatomic, weak) CCAccountData *account;

@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIButton *iconView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UIImageView *selectImg;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation CCAccountListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    return self;
}

- (void)bindCellWithAccount:(CCAccountData *)account {
    self.account = account;
    
    self.backBtn.hidden = YES;
    if (account.account.walletType == CCWalletTypePhone) {
        if (account.account.importType == CCImportTypeSeed) {
            self.backBtn.hidden = account.account.isBackup;
        }
    }
    NSString *icon = [account accountIcon];
    [self.iconView setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    self.nameLab.text = account.account.accountName;
    
    if (account.account.isSelected) {
        self.nameLab.textColor = CC_BTN_ENABLE_COLOR;
        self.iconView.tintColor = self.moreBtn.tintColor = CC_BTN_ENABLE_COLOR;
        self.selectImg.hidden = NO;
        self.borderView.layer.shadowOpacity = .8;
    } else {
        self.nameLab.textColor = CC_BLACK_COLOR;
        self.iconView.tintColor = self.moreBtn.tintColor = CC_GRAY_TEXTCOLOR;
        self.selectImg.hidden = YES;
        self.borderView.layer.shadowOpacity = .3;
    }
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.borderView];
    [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(FitScale(7), FitScale(10), FitScale(5), FitScale(10)));
    }];
    
    [self.borderView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.borderView.mas_left).offset(FitScale(10));
        make.top.equalTo(self.borderView.mas_top).offset(FitScale(15));
    }];
    
    [self.borderView addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.borderView);
        make.width.mas_equalTo(FitScale(30));
    }];
    
    [self.borderView addSubview:self.selectImg];
    [self.selectImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.borderView.mas_centerY);
        make.centerX.equalTo(self.moreBtn.mas_centerX).offset(FitScale(-70));
    }];
    
    [self.borderView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(FitScale(12));
        make.centerY.equalTo(self.iconView.mas_centerY);
        make.right.lessThanOrEqualTo(self.selectImg.mas_left).offset(-FitScale(10));
    }];

    
    [self.borderView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_left);
        make.top.equalTo(self.nameLab.mas_bottom).offset(FitScale(5));
        make.bottom.equalTo(self.borderView.mas_bottom).offset(FitScale(-18));
    }];
    
    @weakify(self)
    [self.moreBtn cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(moreAccountCell:account:targetView:)]) {
            [self.delegate moreAccountCell:self account:self.account targetView:self.moreBtn.imageView];
        }
    }];
}

#pragma mark - get
- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = [UIColor whiteColor];
        _borderView.layer.shadowColor = CC_BTN_ENABLE_COLOR.CGColor;
        _borderView.layer.shadowOffset = CGSizeMake(0, FitScale(1.5));
        _borderView.layer.shadowOpacity = .3;
        _borderView.layer.cornerRadius = FitScale(5);
    }
    return _borderView;
}

- (UIButton *)iconView {
    if (!_iconView) {
        _iconView = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    return _iconView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = CC_BLACK_COLOR;
        _nameLab.font = MediumFont(FitScale(15));
        _nameLab.numberOfLines = 0;
    }
    return _nameLab;
}


- (UIImageView *)selectImg {
    if (!_selectImg) {
        _selectImg = [[UIImageView alloc] init];
        [_selectImg setImage:[UIImage imageNamed:@"cc_address_selected"]];
    }
    return _selectImg;
}


- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_moreBtn setImage:[UIImage imageNamed:@"cc_more_h_point"] forState:UIControlStateNormal];
        _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _moreBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(FitScale(15), 0, 0, FitScale(10));
    }
    return _moreBtn;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setTitle:[NSString stringWithFormat:@"  %@",Localized(@"Unbaked")] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"cc_account_notBackup"] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = MediumFont(FitScale(13));
        [_backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _backBtn.userInteractionEnabled = NO;
    }
    return _backBtn;
}


@end


@implementation CCAccountListFootView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.addBtn];
        [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(40));
            make.center.equalTo(self.contentView);
            make.height.mas_equalTo(FitScale(45));
        }];
    }
    return self;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _addBtn.layer.cornerRadius = FitScale(5);
        _addBtn.layer.masksToBounds = YES;
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = MediumFont(FitScale(14));
        [_addBtn setTitle:Localized(@"Add wallet") forState:UIControlStateNormal];
    }
    return _addBtn;
}

@end
