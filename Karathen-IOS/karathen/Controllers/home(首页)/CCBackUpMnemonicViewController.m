//
//  CCBackUpMnemonicViewController.m
//  Karathen
//
//  Created by Karathen on 2018/7/13.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBackUpMnemonicViewController.h"
#import "CCVerifyMnemonicViewController.h"
#import "CCExportWalletInfoView.h"
#import "CCBackUpMnemonicView.h"

#import "AttributeMaker.h"

@interface CCBackUpMnemonicViewController ()

@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) CCBackUpMnemonicView *backupView;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) CCExportWalletInfoView *exportView;

@end

@implementation CCBackUpMnemonicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createView];
    [self languageChange:nil];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Backup Mnemonic Phrase");
    
    self.descLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        NSString *text = Localized(@"Mnemonic word is the only way to regain the current wallet,please keep them in a safe and secret place.");
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = FitScale(5);
        maker.text(text)
        .paragraph(paragraph);
    }];
    
    
    if (self.type != CCBackUpMnemonicVCExport) {
        [self.finishBtn setTitle:Localized(@"BackUp Finished") forState:UIControlStateNormal];
    }
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(24));
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(22));
    }];
    

    
    if (self.type != CCBackUpMnemonicVCExport) {
        [self.contentView addSubview:self.backupView];
        [self.backupView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.size.mas_equalTo(self.backupView.viewSize);
            make.top.equalTo(self.descLab.mas_bottom).offset(FitScale(20));
        }];
        
        [self.contentView addSubview:self.finishBtn];
        [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.backupView.mas_bottom).offset(FitScale(41));
            make.left.equalTo(self.contentView.mas_left).offset(FitScale(39));
            make.height.mas_equalTo(FitScale(42));
            make.bottom.equalTo(self.contentView.mas_bottom).offset(FitScale(-40));
        }];
        
        @weakify(self)
        [self.finishBtn cc_tapHandle:^{
            @strongify(self)
            [self finishAction];
        }];
    } else {
        [self.contentView addSubview:self.backupView];
        [self.backupView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.descLab.mas_bottom).offset(FitScale(20));
            make.size.mas_equalTo(self.backupView.viewSize);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(FitScale(-20));
        }];
    }
    
    [self setQRCodeItem];

}

#pragma mark - 扫描二维码
- (void)setQRCodeItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, FitScale(60), NAVIGATION_BAR_HEIGHT);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
    [btn setImage:[UIImage imageNamed:@"cc_receive_qrcode_item"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(qrcodeAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)qrcodeAction {
    self.exportView.title = Localized(@"Export mnemonic word");
    self.exportView.hint = [NSString stringWithFormat:Localized(@"Warning Export"),Localized(@"Mnemonic")];
    self.exportView.info = self.mnemonic;
    [self.exportView showView];
}

#pragma mark - action
- (void)finishAction {
    CCVerifyMnemonicViewController *verifyVC = [[CCVerifyMnemonicViewController alloc] init];
    verifyVC.mnemonic = self.mnemonic;
    verifyVC.pinWord = self.pinWord;
    verifyVC.walletName = self.walletName;
    verifyVC.pwdInfo = self.pwdInfo;
    verifyVC.isImport = self.type == CCBackUpMnemonicVCCreate;
    verifyVC.accountData = self.accountData;
    verifyVC.walletType = self.walletType;
    [self.rt_navigationController pushViewController:verifyVC animated:YES complete:nil];
}

#pragma mark - get
- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.textColor = CC_GRAY_TEXTCOLOR;
        _descLab.font = MediumFont(12);
        _descLab.numberOfLines = 0;
    }
    return _descLab;
}

- (CCBackUpMnemonicView *)backupView {
    if (!_backupView) {
        _backupView = [CCBackUpMnemonicView backupViewWithMnemonic:self.mnemonic viewWidth:SCREEN_WIDTH - FitScale(54) viewType:CCBackUpMnemonicTypeCustom];
        _backupView.backgroundColor = CC_GRAY_BACKCOLOR;
        _backupView.layer.cornerRadius = FitScale(8);
    }
    return _backupView;
}

- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _finishBtn.titleLabel.font = MediumFont(FitScale(14));
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _finishBtn.layer.cornerRadius = FitScale(5);
        _finishBtn.layer.masksToBounds = YES;
    }
    return _finishBtn;
}

- (CCExportWalletInfoView *)exportView {
    if (!_exportView) {
        _exportView = [[CCExportWalletInfoView alloc] init];
    }
    return _exportView;
}
@end
