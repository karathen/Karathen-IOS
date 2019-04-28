//
//  CCImportWalletView.m
//  Karathen
//
//  Created by Karathen on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCImportWalletView.h"
#import "MLMSegmentHead.h"
#import "CCWalletTextFieldEditView.h"
#import "UITextView+MLMTextView.h"
#import "CCCoinTypeChooseView.h"
#import "CCAlertView.h"

@interface CCImportWalletView () <CCWalletEditViewDelegate,CCCoinTypeChooseViewDelegate>

@property (nonatomic, weak) CCImportWalletTypeModel *currentModel;
@property (nonatomic, assign) CCCoinType coinType;
@property (nonatomic, assign) CCWalletType walletType;

@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) MLMSegmentHead *segmentHead;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) CCWalletTextFieldEditView *coinTypeView;
@property (nonatomic, strong) UIImageView *moreCoinView;

@property (nonatomic, strong) CCWalletTextFieldEditView *nameView;
@property (nonatomic, strong) CCWalletTextFieldEditView *pwdView;
@property (nonatomic, strong) CCWalletTextFieldEditView *resetPwdView;
@property (nonatomic, strong) CCWalletTextFieldEditView *pwdInfoView;

//
@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) UIButton *importBtn;
@property (nonatomic, strong) CCCoinTypeChooseView *coinChooseView;
@property (nonatomic, strong) CCAlertView *alertView;

@end

@implementation CCImportWalletView

- (instancetype)initWithWalletType:(CCWalletType)walletType {
    if (self = [super init]) {
        self.walletType = walletType;
        [self createView];
        
        [self btnStatusChange];
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    CGFloat topHeight = FitScale(10);
    if (self.walletType == CCWalletTypeHardware) {
        self.coinType = CCImportTypeMnemonic;
    } else {
        [self.contentView addSubview:self.segmentHead];
        topHeight += self.segmentHead.cc_height;
        
        @weakify(self)
        self.segmentHead.selectedIndex = ^(NSInteger index) {
            @strongify(self)
            CCImportWalletTypeModel *model = self.typeArray[index];
            [self layoutViewWithTypeModel:model];
        };
        
    }
    
    [self.contentView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(20));
        make.top.equalTo(self.contentView.mas_top).offset(topHeight);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(FitScale(80));
    }];
    
    [self.contentView addSubview:self.coinTypeView];
    [self.contentView addSubview:self.nameView];
    [self.contentView addSubview:self.pwdView];
    [self.contentView addSubview:self.resetPwdView];
    [self.contentView addSubview:self.pwdInfoView];

    [self layoutViewWithTypeModel:self.typeArray.firstObject];
    
    [self.coinTypeView addSubview:self.moreCoinView];
    [self.moreCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.coinTypeView.descLab.mas_centerY);
        make.right.equalTo(self.coinTypeView.textField.mas_right);
    }];
    
    [self.contentView addSubview:self.importBtn];
    [self.importBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(39));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(FitScale(40));
        make.top.equalTo(self.moreCoinView.mas_bottom).offset(FitScale(30));
    }];
    
    
    [self.contentView addSubview:self.createBtn];
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.importBtn);
        make.top.equalTo(self.importBtn.mas_bottom);
        make.height.equalTo(self.importBtn.mas_height);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(30));
    }];
    
    @weakify(self)
    [self.createBtn cc_tapHandle:^{
        @strongify(self)
        if ([self.importDelegate respondsToSelector:@selector(createActionImportView:)]) {
            [self.importDelegate createActionImportView:self];
        }
    }];
    
    [self.importBtn cc_tapHandle:^{
        @strongify(self)
        [self importAction];
    }];
    
    [self.coinTypeView cc_tapHandle:^{
        @strongify(self)
        [self showCoinTypeChoose];
    }];
}

- (void)changeWalletInfo:(NSString *)walletInfo {
    self.textView.text = walletInfo;
}

#pragma mark - 导入
- (void)importAction {
    [self endEditing:YES];
    if (self.pwdView.text.length < 6) {
        [MBProgressHUD showMessage:self.pwdView.placeholder];
        return;
    }
    switch (self.currentModel.importType) {
        case CCImportTypeMnemonic:
            [self importByMnemonic];
            break;
        case CCImportTypeKeystore:
            [self importByKeystore];
            break;
        case CCImportTypePrivateKey:
            [self importByPrivatekey];
            break;
        case CCImportTypeWIF:
            [self importByWIF];
            break;
        default:
            break;
    }
}

- (void)importByMnemonic {
    if (self.walletType == CCWalletTypeHardware) {
        [self importHardwareByMnemonic];
    } else {
        [self importPhoneByMnemonic];
    }
}

- (void)importPhoneByMnemonic {
    NSString *mnemonic = self.textView.text;
    NSString *pwd = self.pwdView.text;
    NSString *name = self.nameView.text;
    NSString *pwdInfo = self.pwdInfoView.text;
    
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Importing...")];
    @weakify(self)
    [[CCDataManager dataManager] accountWithMnemonic:mnemonic walletType:CCWalletTypePhone importType:CCImportTypeMnemonic passWord:pwd passWordInfo:pwdInfo accountName:name completion:^(BOOL suc, CCWalletError error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.alertView hiddenView];
            if (!suc) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}

- (void)importHardwareByMnemonic {
    NSString *mnemonic = [self.textView.text deleteSpace];
    NSString *pwd = self.pwdView.text;
    NSString *name = self.nameView.text;
    NSString *pwdInfo = self.pwdInfoView.text;
    if (![Account isValidMnemonicPhrase:mnemonic]) {
        [MBProgressHUD showMessage:[CCWalletManager messageWithError:CCWalletErrorMnemonicsValidPhrase]];
        return;
    }
    
    self.alertView.message = Localized(@"Importing...");
    [self.alertView showView];
    @weakify(self)
    //初始化
    [[CCHardwareWallet hardwareWallet] formatDeviceCompletion:^(BOOL success, int errorCode) {
        @strongify(self)
        if (success) {
            //设置密码
            [[CCHardwareWallet hardwareWallet] initPassword:pwd deviceWaiting:^{
                self.alertView.message = Localized(@"Press button to init Password");
            } completion:^(BOOL suc, int errorCode) {
                if (success) {
                    //写入助记词
                    [[CCHardwareWallet hardwareWallet] importSeedWithMnemonic:mnemonic completion:^(BOOL success, int errorCode) {
                        if (success) {
                            //获取地址
                            [[CCHardwareWallet hardwareWallet] getDeviceAddressCompletion:^(BOOL suc, int errorCode, NSDictionary *addressDic) {
                                //写入地址
                                if (suc) {
                                    [[CCDataManager dataManager] accountWithDeviceName:[CCHardwareWallet hardwareWallet].deviceName addressDic:addressDic importType:CCImportTypeMnemonic accountName:name passWordInfo:pwdInfo completion:^(BOOL suc, CCWalletError error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.alertView hiddenView];
                                            if (!suc) {
                                                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
                                            }
                                        });
                                    }];
                                } else {
                                    [self importHardwareFailWithErrorcode:errorCode];
                                }
                            }];
                        } else {
                            [self importHardwareFailWithErrorcode:errorCode];
                        }
                    }];
                } else {
                    [self importHardwareFailWithErrorcode:errorCode];
                }
            }];
        } else {
            [self importHardwareFailWithErrorcode:errorCode];
        }
    } deviceWaiting:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.alertView.message = Localized(@"Press button to format");
        });
    }];
}

- (void)importHardwareFailWithErrorcode:(int)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertView hiddenView];
        [MBProgressHUD showMessage:[Utils errorCodeToString:errorCode]];
    });
}

- (void)importByKeystore {
    NSString *keystore = self.textView.text;
    NSString *pwd = self.pwdView.text;
    NSString *name = self.nameView.text;
    NSString *pwdInfo = self.pwdInfoView.text;
    CCCoinType coinType = self.coinType;
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Importing...")];
    @weakify(self)
    [[CCDataManager dataManager] accountWithKeystore:keystore walletType:CCWalletTypePhone coinType:coinType passWord:pwd passWordInfo:pwdInfo accountName:name completion:^(BOOL suc, CCWalletError error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.alertView hiddenView];
            if (!suc) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });
    }];
}

- (void)importByPrivatekey {
    NSString *private = self.textView.text;
    NSString *pwd = self.pwdView.text;
    NSString *name = self.nameView.text;
    NSString *pwdInfo = self.pwdInfoView.text;
    CCCoinType coinType = self.coinType;
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Importing...")];
    @weakify(self)
    [[CCDataManager dataManager] accountWithPrivatekey:private walletType:CCWalletTypePhone coinType:coinType passWord:pwd passWordInfo:pwdInfo accountName:name completion:^(BOOL suc, CCWalletError error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.alertView hiddenView];
            if (!suc) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });

    }];
}

- (void)importByWIF {
    NSString *wif = self.textView.text;
    NSString *pwd = self.pwdView.text;
    NSString *name = self.nameView.text;
    NSString *pwdInfo = self.pwdInfoView.text;
    CCCoinType coinType = self.coinType;
    self.alertView = [CCAlertView showLoadingMessage:Localized(@"Importing...")];
    @weakify(self)
    [[CCDataManager dataManager] accountWithWIF:wif walletType:CCWalletTypePhone coinType:coinType passWord:pwd passWordInfo:pwdInfo accountName:name completion:^(BOOL suc, CCWalletError error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.alertView hiddenView];
            if (!suc) {
                [MBProgressHUD showMessage:[CCWalletManager messageWithError:error]];
            }
        });

    }];
}

#pragma mark - 选择链
- (void)showCoinTypeChoose {
    if (self.moreCoinView.hidden) {
        return;
    }
    self.coinChooseView.chooseType = self.coinType;
    self.coinChooseView.importType = self.currentModel.importType;
    [self.coinChooseView showTargetView:self.moreCoinView space:FitScale(5)];
}

- (void)setCoinType:(CCCoinType)coinType {
    _coinType = coinType;
    [self.coinTypeView setText:[CCDataManager coinKeyWithType:coinType]];
}

#pragma mark - btnStatusChange
- (void)btnStatusChange {
    BOOL judge = [self judgeComplete];
    if (judge) {
        self.importBtn.userInteractionEnabled = YES;
        self.importBtn.backgroundColor = CC_MAIN_COLOR;
    } else {
        self.importBtn.userInteractionEnabled = NO;
        self.importBtn.backgroundColor = CC_BTN_DISABLE_COLOR;
    }
}

- (BOOL)judgeComplete {
    if (self.textView.text.length == 0) {
        return NO;
    }
    if (self.nameView.text.length == 0) {
        return NO;
    }
    if (self.pwdView.text.length == 0) {
        return NO;
    }
    if (self.currentModel.importType != CCImportTypeKeystore) {
        if (![self.resetPwdView.text isEqualToString:self.pwdView.text]) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - layout
- (void)layoutViewWithTypeModel:(CCImportWalletTypeModel *)model {
    self.currentModel = model;
    [self btnStatusChange];
    //切换清空数据
    self.textView.text = nil;
    [self.coinTypeView clearText];
    [self.nameView clearText];
    [self.pwdView clearText];
    [self.resetPwdView clearText];
    [self.pwdInfoView clearText];
    
    CCImportType importType = model.importType;
    self.textView.mlm_placeholder = model.placeHolder;
    UIView *lastView = self.textView;
    CGFloat topSpace = FitScale(6);
    
    self.coinTypeView.hidden = YES;
    if (importType != CCImportTypeMnemonic) {
        self.coinChooseView.importType = self.currentModel.importType;
        self.coinTypeView.hidden = NO;
        [self.coinTypeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.top.equalTo(lastView.mas_bottom).offset(topSpace);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        
        topSpace = 0;
        lastView = self.coinTypeView;
        
        self.moreCoinView.hidden = self.coinChooseView.coins.count <= 1;
        self.coinType = [self.coinChooseView.coins.firstObject integerValue];
    }

    [self.nameView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(lastView.mas_bottom).offset(topSpace);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.pwdView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.nameView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    lastView = self.pwdView;
    self.resetPwdView.hidden = YES;
    if (importType != CCImportTypeKeystore) {
        self.resetPwdView.hidden = NO;
        [self.resetPwdView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.top.equalTo(lastView.mas_bottom);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
        
        lastView = self.resetPwdView;
        self.pwdView.title = Localized(@"Set password");
        self.pwdView.placeholder = self.walletType==CCWalletTypeHardware?Localized(@"Please enter 6-digital number password"):Localized(@"Please enter the password with at least 6 numbers");
    } else {
        self.pwdView.title = Localized(@"Keystore password");
        self.pwdView.placeholder = Localized(@"Please input keystore password");

    }

    
    [self.pwdInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(lastView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
}

#pragma mark - CCCoinTypeChooseViewDelegate
- (void)chooseView:(CCCoinTypeChooseView *)chooseView coinType:(CCCoinType)coinType {
    self.coinType = coinType;
}

#pragma mark - CCWalletEditViewDelegate
- (void)textChangeInfoView:(CCWalletTextFieldEditView *)infoView {
    [self btnStatusChange];
}


#pragma mark - get
- (NSArray *)typeArray {
    if (!_typeArray) {
        CCImportWalletTypeModel *mnemonic = [[CCImportWalletTypeModel alloc] initWithType:CCImportTypeMnemonic];
        CCImportWalletTypeModel *keystore = [[CCImportWalletTypeModel alloc] initWithType:CCImportTypeKeystore];
        CCImportWalletTypeModel *privatekey = [[CCImportWalletTypeModel alloc] initWithType:CCImportTypePrivateKey];
        CCImportWalletTypeModel *wif = [[CCImportWalletTypeModel alloc] initWithType:CCImportTypeWIF];
        
        _typeArray = @[
                       mnemonic,
                       keystore,
                       privatekey,
                       wif
                       ];
    }
    return _typeArray;
}

- (MLMSegmentHead *)segmentHead {
    if (!_segmentHead) {
        NSMutableArray *titles = [NSMutableArray array];
        for (CCImportWalletTypeModel *model in self.typeArray) {
            [titles addObject:model.title];
        }
        _segmentHead = [[MLMSegmentHead alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FitScale(45)) titles:titles headStyle:SegmentHeadStyleDefault layoutStyle:MLMSegmentLayoutDefault];
        _segmentHead.selectColor = CC_MAIN_COLOR;
        _segmentHead.deSelectColor = CC_BLACK_COLOR;
        _segmentHead.fontSize = FitScale(15);
        _segmentHead.bottomLineHeight = 0;
        [_segmentHead defaultAndCreateView];
    }
    return _segmentHead;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.mlm_placeholderColor = CC_GRAY_TEXTCOLOR;
        _textView.textColor = CC_BLACK_COLOR;
        _textView.layer.borderWidth = .6;
        _textView.layer.borderColor = CC_GRAY_LINECOLOR.CGColor;
        _textView.font = MediumFont(FitScale(13));
        @weakify(self)
        _textView.textDidChange = ^(NSString *text) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self btnStatusChange];
            });
        };
        [_textView refreshPlaceholderView];
    }
    return _textView;
}

- (CCWalletTextFieldEditView *)coinTypeView {
    if (!_coinTypeView) {
        _coinTypeView = [[CCWalletTextFieldEditView alloc] initWithTitle:nil placeholder:@"请选择链"];
        _coinTypeView.textField.userInteractionEnabled = NO;
    }
    return _coinTypeView;
}

- (UIImageView *)moreCoinView {
    if (!_moreCoinView) {
        _moreCoinView = [[UIImageView alloc] init];
        [_moreCoinView setImage:[UIImage imageNamed:@"cc_more_arrow"]];
    }
    return _moreCoinView;
}


- (CCWalletTextFieldEditView *)nameView {
    if (!_nameView) {
        _nameView = [[CCWalletTextFieldEditView alloc] initWithTitle:Localized(@"Wallet name") placeholder:Localized(@"Please input wallet name")];
        _nameView.delegate = self;
    }
    return _nameView;
}

- (CCWalletTextFieldEditView *)pwdView {
    if (!_pwdView) {
        _pwdView = [[CCWalletTextFieldEditView alloc] initWithTitle:Localized(@"Set password") placeholder:self.walletType==CCWalletTypeHardware?Localized(@"Please enter 6-digital number password"):Localized(@"Please enter the password with at least 6 numbers")];
        if (self.walletType == CCWalletTypeHardware) {
            _pwdView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _pwdView.textField.maxLength = 6;
        }
        _pwdView.textField.secureTextEntry = YES;
        _pwdView.delegate = self;
    }
    return _pwdView;
}

- (CCWalletTextFieldEditView *)resetPwdView {
    if (!_resetPwdView) {
        _resetPwdView = [[CCWalletTextFieldEditView alloc] initWithTitle:Localized(@"Confirm password") placeholder:Localized(@"Confirm password")];
        if (self.walletType == CCWalletTypeHardware) {
            _resetPwdView.textField.keyboardType = UIKeyboardTypeNumberPad;
            _resetPwdView.textField.maxLength = 6;
        }
        _resetPwdView.textField.secureTextEntry = YES;
        _resetPwdView.delegate = self;
    }
    return _resetPwdView;
}

- (CCWalletTextFieldEditView *)pwdInfoView {
    if (!_pwdInfoView) {
        _pwdInfoView = [[CCWalletTextFieldEditView alloc] initWithTitle:Localized(@"Prompt message") placeholder:Localized(@"Please input prompt message")];
        _pwdInfoView.delegate = self;
    }
    return _pwdInfoView;
}


- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _createBtn.backgroundColor = [UIColor clearColor];
        [_createBtn setTitleColor:CC_MAIN_COLOR forState:UIControlStateNormal];
        _createBtn.titleLabel.font = MediumFont(FitScale(14));
        [_createBtn setTitle:Localized(@"Create Wallet") forState:UIControlStateNormal];
    }
    return _createBtn;
}

- (UIButton *)importBtn {
    if (!_importBtn) {
        _importBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _importBtn.backgroundColor = CC_MAIN_COLOR;
        _importBtn.layer.cornerRadius = FitScale(5);
        _importBtn.layer.masksToBounds = YES;
        [_importBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _importBtn.titleLabel.font = MediumFont(FitScale(14));
        [_importBtn setTitle:Localized(@"Import Wallet") forState:UIControlStateNormal];
    }
    return _importBtn;
}

- (CCCoinTypeChooseView *)coinChooseView {
    if (!_coinChooseView) {
        _coinChooseView = [[CCCoinTypeChooseView alloc] initWithImportType:self.currentModel.importType chooseType:self.coinType];
        _coinChooseView.chooseDelegate = self;
    }
    return _coinChooseView;
}

@end

@implementation CCImportWalletTypeModel

- (instancetype)initWithType:(CCImportType)importType {
    if (self = [super init]) {
        self.importType = importType;
        switch (importType) {
            case CCImportTypeMnemonic:
            {
                self.title = Localized(@"Mnemonic");
                self.placeHolder = Localized(@"Please separate each mnemonic word with a space");
            }
                break;
            case CCImportTypeKeystore:
            {
                self.title = Localized(@"Keystore");
                self.placeHolder = Localized(@"Please input keystore");
            }
                break;
            case CCImportTypePrivateKey:
            {
                self.title = Localized(@"Private Key");
                self.placeHolder = Localized(@"Please input your private key");
            }
                break;
            case CCImportTypeWIF:
            {
                self.title = Localized(@"WIF");
                self.placeHolder = Localized(@"Please input your WIF");
            }
                break;
            default:
                break;
        }
    }
    return self;
}

@end
