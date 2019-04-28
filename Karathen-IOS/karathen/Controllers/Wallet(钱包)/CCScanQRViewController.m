//
//  CCScanQRViewController.m
//  Karathen
//
//  Created by Karathen on 2018/8/1.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCScanQRViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "CCSubLBXScanViewController+ScanQR.h"
#import "CCAlertView.h"
#import "CCScanResultViewController.h"

@interface CCScanQRViewController () <LBXScanViewControllerDelegate, CCAlertViewDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong) CCSubLBXScanViewController *scanVC;
@property (nonatomic, strong) CCAlertView *alertView;
@property (nonatomic, strong) UIButton *choosePhotoBtn;
@end

@implementation CCScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self languageChange:nil];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.navigationItem.title = Localized(@"Scan");
    [self.scanVC languageChange];
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.scanVC.view];
    [self addChildViewController:self.scanVC];
    
    [self.scanVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.choosePhotoBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    @weakify(self)
    [self.choosePhotoBtn cc_tapHandle:^{
        @strongify(self)
        [self choosePhoto];
    }];
}

#pragma mark - choosePhoto
- (void)choosePhoto {
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePicker.allowTakeVideo = NO;
    imagePicker.allowTakePicture = NO;
    imagePicker.allowPickingVideo = NO;
    
    imagePicker.navigationBar.translucent = NO;
    [imagePicker.navigationBar setShadowImage:[UIImage new]];
    imagePicker.navigationBar.barTintColor = CC_BTN_ENABLE_COLOR;
    imagePicker.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    imagePicker.oKButtonTitleColorNormal = CC_BTN_ENABLE_COLOR;
    imagePicker.navigationBar.translucent = NO;
    imagePicker.cancelBtnTitleStr = [NSString stringWithFormat:@"%@  ",Localized(@"Cancel")];
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    UIImage *image = photos.firstObject;
    @weakify(self)
    [LBXScanNative recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
        @strongify(self)
        [self scanResultWithArray:array];
    }];
}

#pragma mark - CCAlertViewDelegate
- (void)alertViewDidHidden:(CCAlertView *)alertView {
    [self.scanVC reStartDevice];
}

#pragma mark - LBXScanViewControllerDelegate
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array {
    switch (self.ruleType) {
        case CCQRCodeRuleTypeNone:
        {
            @weakify(self)
            [CCQRCodeRule scanNoneTypeCode:array completion:^(BOOL suc, NSString *message) {
                @strongify(self)
                if (suc) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(scanVC:result:)]) {
                        [self.delegate scanVC:self result:message];
                    }
                } else {
                    [self showMessage:message];
                }
            }];
        }
            break;
        case CCQRCodeRuleTypeReceive:
        {
            @weakify(self)
            [CCQRCodeRule scanReceiveQRCode:array currentWallet:self.walletData currentAsset:self.asset completion:^(NSString *message, NSString *scanResult, NSString *toAddress, CCAsset *asset) {
                @strongify(self)
                [self dealMessage:message scanResult:scanResult toAddress:toAddress asset:asset];
            }];
        }
            break;
        default:
            break;
    }

}

#pragma mark -
- (void)showMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alertView.message = message;
        self.alertView.sureTitle = Localized(@"OK");
        [self.alertView showView];
    });
}

#pragma mark - 处理结果
- (void)dealMessage:(NSString *)message scanResult:(NSString *)scanResult toAddress:(NSString *)toAddress asset:(CCAsset *)asset {
    if (message) {
        [self showMessage:message];
    } else {
        if (!toAddress && !asset) {
            [self showScanResult:scanResult];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scanVC:tradeToAddress:asset:)]) {
                [self.delegate scanVC:self tradeToAddress:toAddress asset:asset];
            }
        }
    }
}

- (void)showScanResult:(NSString *)scanResult {
    if (scanResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CCScanResultViewController *resultVC = [[CCScanResultViewController alloc] init];
            resultVC.scanResult = scanResult;
            [self.rt_navigationController pushViewController:resultVC animated:YES complete:nil];
        });
    }
}

#pragma mark - scanVC
- (CCSubLBXScanViewController *)scanVC {
    if (!_scanVC) {
        _scanVC = [CCSubLBXScanViewController customScanVC];
        _scanVC.delegate = self;
    }
    return _scanVC;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeTextAlert];
        _alertView.delegate = self;
    }
    return _alertView;
}

- (UIButton *)choosePhotoBtn {
    if (!_choosePhotoBtn) {
        _choosePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choosePhotoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _choosePhotoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, FitScale(10));
        [_choosePhotoBtn setImage:[UIImage imageNamed:@"cc_choose_photo"] forState:UIControlStateNormal];
    }
    return _choosePhotoBtn;
}

@end
