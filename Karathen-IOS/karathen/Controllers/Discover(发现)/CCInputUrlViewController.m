//
//  CCInputUrlViewController.m
//  Karathen
//
//  Created by Karathen on 2018/10/25.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCInputUrlViewController.h"
#import "AttributeMaker.h"
#import "CCDappViewController.h"

@interface CCInputUrlViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation CCInputUrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.rt_disableInteractivePop = NO;

    [self createView];
}

#pragma mark - createView
- (void)createView {
    UIView *topView = [self topView];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
    }];
    
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom).offset(FitScale(100));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.view addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(FitScale(65));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.imageView.mas_bottom).offset(FitScale(15));
    }];
}

- (UIView *)topView {
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor whiteColor];
    topView.layer.shadowColor = CC_BLACK_COLOR.CGColor;
    topView.layer.shadowOffset = CGSizeMake(0, FitScale(1.5));
    topView.layer.shadowOpacity = .3;

    [topView addSubview:self.urlTextField];
    [self.urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView.mas_left).offset(FitScale(5));
        make.top.equalTo(topView.mas_top).offset(STATUS_BAR_HEIGHT);
        make.bottom.equalTo(topView.mas_bottom);
        make.height.mas_equalTo(NAVIGATION_BAR_HEIGHT);
    }];
    
    [topView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.urlTextField);
        make.right.equalTo(topView.mas_right);
        make.left.equalTo(self.urlTextField.mas_right);
        make.width.mas_equalTo(FitScale(55));
    }];
    
    @weakify(self)
    [self.cancelBtn cc_tapHandle:^{
        @strongify(self)
        [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
    }];
    
    return topView;
}

#pragma mark - action
- (void)gotoDapp {
    CCDappViewController *dappVC = [[CCDappViewController alloc] init];
    dappVC.url = [NSString getCompleteWebsite:self.urlTextField.text];
    [self.rt_navigationController pushViewController:dappVC animated:YES complete:nil];
    self.urlTextField.text = @"";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self gotoDapp];
    return YES;
}


#pragma mark - get
- (UITextField *)urlTextField {
    if (!_urlTextField) {
        _urlTextField = [[UITextField alloc] init];
        _urlTextField.placeholder = Localized(@"Input Dapp PlaceHolder");
        _urlTextField.font = MediumFont(FitScale(14));
        _urlTextField.returnKeyType = UIReturnKeyGo;
        _urlTextField.delegate = self;
        _urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _urlTextField;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:Localized(@"Cancel") forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = MediumFont(FitScale(14));
        [_cancelBtn setTitleColor:CC_BTN_TITLE_COLOR forState:UIControlStateNormal];
    }
    return _cancelBtn;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setImage:[UIImage imageNamed:@"cc_internet"]];
    }
    return _imageView;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.textColor = CC_GRAY_TEXTCOLOR;
        _hintLabel.font = MediumFont(FitScale(13));
        _hintLabel.numberOfLines = 0;
        _hintLabel.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
            NSString *text = Localized(@"Input Dapp Hint");
            NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
            pStyle.lineSpacing = FitScale(5);
            pStyle.alignment = NSTextAlignmentCenter;
            maker.text(text)
            .paragraph(pStyle);
        }];
    }
    return _hintLabel;
}

@end
