//
//  CCContactServiceViewController.m
//  Karathen
//
//  Created by Karathen on 2018/10/25.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCContactServiceViewController.h"
#import "CCWalletTextFieldEditView.h"
#import "CCWalletTextViewEditView.h"
#import "CCChooseImageView.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "CCUpImageManage.h"
#import "CCAlertView.h"
#import "CCTechnicalSupportRequest.h"

static NSInteger maxCount = 3;
@interface CCContactServiceViewController () <CCWalletEditViewDelegate,CCChooseImageViewDelegate>

@property (nonatomic, strong) CCWalletTextFieldEditView *emailView;
@property (nonatomic, strong) CCWalletTextFieldEditView *phoneView;
@property (nonatomic, strong) CCWalletTextFieldEditView *titleView;
@property (nonatomic, strong) CCWalletTextViewEditView *descView;
@property (nonatomic, strong) CCChooseImageView *chooseImgView;

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UIButton *commitBtn;
@property (nonatomic, strong) CCUpImageManage *upImages;
@property (nonatomic, strong) CCAlertView *alertView;
@property (nonatomic, strong) CCTechnicalSupportRequest *suportRequest;

@end

@implementation CCContactServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createView];
    [self languageChange:nil];
}

#pragma mark - super method
- (void)languageChange:(NSString *)language {
    self.title = Localized(@"Technical Support");
    
    self.emailView.title = Localized(@"Email");
    self.emailView.placeholder =  Localized(@"Please input email address");
    self.phoneView.title = Localized(@"Phone");
    self.phoneView.placeholder = Localized(@"Please input email phone number");
    self.titleView.title = Localized(@"Title");
    self.titleView.placeholder = Localized(@"Please input title");
    self.descView.title = Localized(@"Description");
    self.descView.placeholder = Localized(@"Please provide details about the problem, we will reply to you as soon as possible");
    
    [self.commitBtn setTitle:Localized(@"Submit") forState:UIControlStateNormal];
}

#pragma mark - createView
- (void)createView {
    self.scrollView.bounces = YES;
    
    [self.contentView addSubview:self.emailView];
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.contentView.mas_top).offset(FitScale(6));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.phoneView];
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.emailView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.phoneView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.descView];
    [self.descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.equalTo(self.titleView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.chooseImgView];
    [self.chooseImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descView.mas_bottom);
        make.left.right.equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(20));
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.chooseImgView.mas_bottom).offset(FitScale(20));
        make.height.mas_equalTo(FitScale(45));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-FitScale(30));
    }];
    
    [self addRedStarLabToView:self.emailView];
    [self addRedStarLabToView:self.titleView];
    [self addRedStarLabToView:self.descView];
    
    @weakify(self)
    [self.commitBtn cc_tapHandle:^{
        @strongify(self)
        [self commitAction];
    }];
}

- (void)addRedStarLabToView:(CCWalletEditView *)editView {
    UILabel *redLab = [self redStarLab];
    [editView addSubview:redLab];
    [redLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(editView.titleLab.mas_right);
        make.top.equalTo(editView.titleLab.mas_top);
    }];
}

#pragma mark - 检查是否填了必填项
- (BOOL)emptyCheckEditView {
    if (self.emailView.text.length == 0) {
        [MBProgressHUD showMessage:self.emailView.placeholder];
        return YES;
    }
    
    if (![NSString validateEmail:self.emailView.text]) {
        [MBProgressHUD showMessage:Localized(@"Email address invalid")];
        return YES;
    }
    
    if (self.titleView.text.length == 0) {
        [MBProgressHUD showMessage:self.titleView.placeholder];
        return YES;
    }
    if (self.descView.text.length == 0) {
        [MBProgressHUD showMessage:Localized(@"Please input description")];
        return YES;
    }
    
    return NO;
}

#pragma mark - commitAction
- (void)commitAction {
    if ([self emptyCheckEditView]) {
        return;
    }
    [self.alertView showView];
    self.alertView.message = Localized(@"Submitting...");
    self.upImages.images = self.chooseImgView.imageArray;
    @weakify(self)
    [self.upImages startUploadCompletion:^(NSArray *urls) {
        @strongify(self)
        [self commitWithUrls:urls];
    }];
}

- (void)commitWithUrls:(NSArray *)urls {
    self.suportRequest.email = self.emailView.text;
    self.suportRequest.telephone = self.phoneView.text;
    self.suportRequest.title = self.titleView.text;
    self.suportRequest.content = self.descView.text;
    self.suportRequest.urls = urls;
    @weakify(self)
    [self.suportRequest supportRequet:^(BOOL suc, NSString * _Nonnull msg) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hiddenView];
            [MBProgressHUD showMessage:msg];
            if (suc) {
                [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
            }
        });
    }];
}

#pragma mark - CCChooseImageViewDelegate
- (void)deleteImageWithView:(CCChooseImageView *)chooseView imageIndex:(NSInteger)index {
    [self.assets removeObjectAtIndex:index];
    [chooseView.imageArray removeObjectAtIndex:index];
    [chooseView reloadData];
}

- (void)chooseImageWithView:(CCChooseImageView *)chooseView imageIndex:(NSInteger)index {
    if (index < chooseView.imageArray.count) {
        [self showPreViewWithIndex:index];
    } else {
        [self showImagePicker];
    }
}

- (void)showPreViewWithIndex:(NSInteger)index {
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithSelectedAssets:self.assets selectedPhotos:self.chooseImgView.imageArray index:index];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showImagePicker {
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePicker.allowTakeVideo = NO;
    imagePicker.allowTakePicture = YES;
    imagePicker.allowPickingVideo = NO;
    imagePicker.navigationBar.translucent = NO;
    [imagePicker.navigationBar setShadowImage:[UIImage new]];
    imagePicker.navigationBar.barTintColor = CC_BTN_ENABLE_COLOR;
    imagePicker.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    imagePicker.oKButtonTitleColorNormal = CC_BTN_ENABLE_COLOR;
    imagePicker.navigationBar.translucent = NO;
    imagePicker.selectedAssets = self.assets;
    @weakify(self)
    imagePicker.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
        @strongify(self)
        self.assets = [assets mutableCopy];
        self.chooseImgView.imageArray = [photos mutableCopy];
        [self.chooseImgView reloadData];
    };
    imagePicker.cancelBtnTitleStr = [NSString stringWithFormat:@"%@  ",Localized(@"Cancel")];
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (UILabel *)redStarLab {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"*";
    label.textColor = [UIColor redColor];
    return label;
}

#pragma mark - get
- (CCWalletTextFieldEditView *)emailView {
    if (!_emailView) {
        _emailView = [[CCWalletTextFieldEditView alloc] init];
        _emailView.delegate = self;
    }
    return _emailView;
}

- (CCWalletTextFieldEditView *)phoneView {
    if (!_phoneView) {
        _phoneView = [[CCWalletTextFieldEditView alloc] init];
        _phoneView.delegate = self;
    }
    return _phoneView;
}

- (CCWalletTextFieldEditView *)titleView {
    if (!_titleView) {
        _titleView = [[CCWalletTextFieldEditView alloc] init];
        _titleView.delegate = self;
    }
    return _titleView;
}


- (CCWalletTextViewEditView *)descView {
    if (!_descView) {
        _descView = [[CCWalletTextViewEditView alloc] init];
        _descView.delegate = self;
    }
    return _descView;
}

- (CCChooseImageView *)chooseImgView {
    if (!_chooseImgView) {
        _chooseImgView = [[CCChooseImageView alloc] initWithTitle:Localized(@"Photo") maxChoose:maxCount viewWidth:SCREEN_WIDTH columnNum:3];
        _chooseImgView.delegate = self;
    }
    return _chooseImgView;
}

- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitBtn.backgroundColor = CC_BTN_ENABLE_COLOR;
        _commitBtn.layer.cornerRadius = FitScale(5);
        _commitBtn.layer.masksToBounds = YES;
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _commitBtn.titleLabel.font = MediumFont(FitScale(14));
    }
    return _commitBtn;
}

- (CCUpImageManage *)upImages {
    if (!_upImages) {
        _upImages = [[CCUpImageManage alloc] init];
    }
    return _upImages;
}

- (CCTechnicalSupportRequest *)suportRequest {
    if (!_suportRequest) {
        _suportRequest = [[CCTechnicalSupportRequest alloc] init];
    }
    return _suportRequest;
}

- (CCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [CCAlertView alertViewMessage:nil sureTitle:nil withType:CCAlertViewTypeLoading];
    }
    return _alertView;
}

@end
