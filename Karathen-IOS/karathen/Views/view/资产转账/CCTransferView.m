//
//  CCTransferView.m
//  Karathen
//
//  Created by Karathen on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTransferView.h"
#import "CCWalletTextFieldEditView.h"
#import "CCButtonView.h"
#import "CCChangeWalletView.h"
#import "CCErc721DetailView.h"
#import "CCErc721TokenInfoModel.h"

@interface CCTransferView () <CCWalletEditViewDelegate>

@property (nonatomic, strong) CCErc721DetailView *erc721View;
@property (nonatomic, strong) NSString *toAddress;
@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) CCWalletTextFieldEditView *numberView;
@property (nonatomic, strong) UILabel *numberLab;

@property (nonatomic, strong) CCWalletTextFieldEditView *addressView;
@property (nonatomic, strong) CCWalletEditView *fromAddressView;
@property (nonatomic, strong) CCWalletTextFieldEditView *remarkView;
@property (nonatomic, strong) CCButtonView *changeWalletBtn;
@property (nonatomic, strong) UIButton *transferBtn;

@property (nonatomic, strong) UILabel *descLab;

//gas
@property (nonatomic, strong) NSString *gasPrice;
@property (nonatomic, strong) CCChangeWalletView *chooseView;
@property (nonatomic, weak) CCErc721TokenInfoModel *tokenModel;

@end

@implementation CCTransferView

- (instancetype)initWithAsset:(CCAsset *)asset
                   walletData:(CCWalletData *)walletData
                    toAddress:(NSString *)toAddress {
    if (self = [super init]) {
        self.asset = asset;
        self.walletData = walletData;
        self.toAddress = toAddress;
        
        self.backgroundColor = [UIColor whiteColor];
        self.bounces = NO;
        self.showsVerticalScrollIndicator = NO;

        [self createView];
        [self btnStatusChange];
        
        [self bindWallet];
    }
    return self;
}

- (void)bindWallet {
    self.fromAddressView.placeholder = self.walletData.address;
    self.changeWalletBtn.titleLab.text = self.walletData.walletName;
    
    self.numberLab.text = [NSString stringWithFormat:@"%@:%@%@",Localized(@"Balance"),self.asset.balance,self.asset.tokenSynbol];
    
    if (self.walletData.type == CCCoinTypeONT) {
        self.descLab.text = Localized(@"ONT Transfer hint");
    }
    
//    //切换钱包打开
//    CCAsset *asset = [self.walletData assetWithToken:self.asset.tokenAddress];
//    if (asset) {
//        self.numberLab.text = [NSString stringWithFormat:@"%@:%@%@",Localized(@"Balance"),asset.balance,self.asset.tokenSynbol];
//    } else {
//        self.numberLab.text = [NSString stringWithFormat:@"%@:%@%@",Localized(@"Balance"),@"--",self.asset.tokenSynbol];
//    }
}

- (void)changeToAddress:(NSString *)toAddress {
    self.toAddress = toAddress;
    self.addressView.text = self.toAddress;
    [self btnStatusChange];
}

- (void)bindTokenModel:(CCErc721TokenInfoModel *)tokenModel {
    self.tokenModel = tokenModel;
    [self.erc721View bindTokenModel:tokenModel withAsset:self.asset];
}

#pragma mark - 检测
- (void)btnStatusChange {
    BOOL judge = [self judgeComplete];
    if (judge) {
        self.transferBtn.userInteractionEnabled = YES;
        self.transferBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
    } else {
        self.transferBtn.userInteractionEnabled = NO;
        self.transferBtn.backgroundColor = CC_BTN_DISABLE_COLOR;
    }
}

- (BOOL)judgeComplete {
    if (self.addressView.text.length == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - topView
- (UIView *)topView {
    if ([self isErc721]) {
        return self.erc721View;
    } else {
        [self.numberView addSubview:self.numberLab];
        [self.numberLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.numberView.lineView.mas_right);
            make.centerY.equalTo(self.numberView.titleLab.mas_centerY);
        }];
        [self.numberLab setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        return self.numberView;
    }
}

#pragma mark - initView
- (void)createView {
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    UIView *topView = [self topView];
    [self.contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(6));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];

    [self.contentView addSubview:self.addressView];
    [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(topView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.fromAddressView];
    [self.fromAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.addressView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.fromAddressView addSubview:self.changeWalletBtn];
    [self.changeWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fromAddressView.lineView.mas_right);
        make.centerY.equalTo(self.fromAddressView.titleLab.mas_centerY);
        make.top.equalTo(self.fromAddressView.mas_top);
        make.width.mas_equalTo(0);
    }];
    
    [self.contentView addSubview:self.remarkView];
    [self.remarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.fromAddressView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.transferBtn];
    [self.transferBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(40));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(self.remarkView.mas_bottom).offset(FitScale(30));
    }];
    
    [self.contentView addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.transferBtn);
        make.top.equalTo(self.transferBtn.mas_bottom).offset(FitScale(20));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(20));
    }];
    
    @weakify(self)
    [self.transferBtn cc_tapHandle:^{
        @strongify(self)
        [self transferAction];
    }];
    
    [self.changeWalletBtn cc_tapHandle:^{
        @strongify(self)
        [self showChooseView];
    }];
    
}

#pragma mark - 是否是721
- (BOOL)isErc721 {
    return [self.asset.tokenType compareWithString:CCAseet_ETH_ERC721];
}


#pragma mark - 转账
- (void)transferAction {
    [self endEditing:YES];

    NSString *number;
    if (![self isErc721]) {
        //检查余额
        NSDecimalNumber *transferNum = [NSDecimalNumber decimalNumberWithString:self.numberView.text];
        NSDecimalNumber *maxNum = [NSDecimalNumber decimalNumberWithString:self.asset.balance?:@"0"];
        NSComparisonResult result = [maxNum compare:transferNum];
        if (result == NSOrderedAscending) {
            [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletErrorNSOrderedDescending]];
            return;
        }
        number = self.numberView.text;
    } else {
        number = self.tokenModel.tokenId;
    }
    
    //检验地址
    if (![CCWalletData checkAddress:self.addressView.text coinType:self.walletData.type]) {
        [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletAddressWrong]];
        return;
    }
    
    //NEP-5不能给自己交易
    if ([self.asset.tokenType compareWithString:CCAseet_NEO_Nep_5] && [self.walletData.address compareWithString:self.addressView.text]) {
        [MBProgressHUD showMessage:Localized(@"Same address cannot make transaction")];
        return;
    }
    
    if (self.transferDelegate && [self.transferDelegate respondsToSelector:@selector(transferView:remark:toAddress:number:)]) {
        [self.transferDelegate transferView:self remark:self.remarkView.text toAddress:self.addressView.text number:number];
    }
}

#pragma mark - 选择钱包
- (void)showChooseView {
    [self.chooseView showTargetView:self.changeWalletBtn.imageView space:FitScale(3)];
    @weakify(self)
    self.chooseView.chooseWallet = ^(CCWalletData *walletData) {
        @strongify(self)
        self.walletData = walletData;
        [self bindWallet];
    };
}


#pragma mark - CCWalletEditViewDelegate
- (void)textChangeInfoView:(CCWalletTextFieldEditView *)infoView {
    [self btnStatusChange];
}


#pragma mark - set
- (void)setToAddress:(NSString *)toAddress {
    _toAddress = toAddress;
    if (toAddress) {
        self.addressView.text = toAddress;
    }
}

#pragma mark - get
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (CCWalletTextFieldEditView *)numberView {
    if (!_numberView) {
        _numberView = [[CCWalletTextFieldEditView alloc] init];
        _numberView.delegate = self;
        _numberView.textField.onlyNum = YES;
        NSInteger tokenDecimal = self.asset.tokenDecimal.integerValue;
        if (tokenDecimal > 0) {
            _numberView.textField.hasPoint = YES;
            _numberView.textField.afterPoint = tokenDecimal;
        } else {
            _numberView.textField.hasPoint = NO;
            _numberView.textField.afterPoint = tokenDecimal;
        }
        _numberView.textField.keyboardType = UIKeyboardTypeDecimalPad;
        
        _numberView.title = self.asset.tokenSynbol;
        _numberView.placeholder = Localized(@"Input the amount");
    }
    return _numberView;
}

- (CCWalletTextFieldEditView *)addressView {
    if (!_addressView) {
        _addressView = [[CCWalletTextFieldEditView alloc] init];
        _addressView.delegate = self;
        _addressView.title = Localized(@"Recipient Address");
        _addressView.placeholder = Localized(@"Paste the recipient address");
    }
    return _addressView;
}

- (CCWalletEditView *)fromAddressView {
    if (!_fromAddressView) {
        _fromAddressView = [[CCWalletEditView alloc] init];
        _fromAddressView.title = Localized(@"Transfer Address");
    }
    return _fromAddressView;
}

- (CCWalletTextFieldEditView *)remarkView {
    if (!_remarkView) {
        _remarkView = [[CCWalletTextFieldEditView alloc] init];
        _remarkView.delegate = self;
        _remarkView.title = Localized(@"Remark");
        _remarkView.placeholder = Localized(@"Remark");
    }
    return _remarkView;
}

- (UILabel *)numberLab {
    if (!_numberLab) {
        _numberLab = [[UILabel alloc] init];
        _numberLab.textColor = CC_BLACK_COLOR;
        _numberLab.font = MediumFont(FitScale(13));
    }
    return _numberLab;
}
- (UIButton *)transferBtn {
    if (!_transferBtn) {
        _transferBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _transferBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _transferBtn.layer.cornerRadius = FitScale(5);
        _transferBtn.layer.masksToBounds = YES;
        [_transferBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _transferBtn.titleLabel.font = MediumFont(FitScale(14));
        [_transferBtn setTitle:Localized(@"Transfer") forState:UIControlStateNormal];
    }
    return _transferBtn;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(FitScale(12));
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}


- (CCButtonView *)changeWalletBtn {
    if (!_changeWalletBtn) {
        _changeWalletBtn = [[CCButtonView alloc] init];
        _changeWalletBtn.titleLab.textColor = CC_GRAY_TEXTCOLOR;
        _changeWalletBtn.titleLab.font = MediumFont(FitScale(13));
        [_changeWalletBtn.imageView setImage:[UIImage imageNamed:@"cc_gray_arrow"]];
    }
    return _changeWalletBtn;
}

- (CCChangeWalletView *)chooseView {
    if (!_chooseView) {
        _chooseView = [[CCChangeWalletView alloc] initWithAsset:self.asset walletData:self.walletData];
    }
    return _chooseView;
}

- (CCErc721DetailView *)erc721View {
    if (!_erc721View) {
        _erc721View = [[CCErc721DetailView alloc] init];
    }
    return _erc721View;
}

@end
