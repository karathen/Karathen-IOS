
//
//  CCScanResultViewController.m
//  ccAsset
//
//  Created by SealWallet on 2018/12/7.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCScanResultViewController.h"
#import "CCEdgeLabel.h"
#import "AttributeMaker.h"

@interface CCScanResultViewController ()

@property (nonatomic, strong) CCEdgeLabel *contentLab;

@end


@implementation CCScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localized(@"Scan results");
    [self createView];
    
}

- (void)createView {
    [self.contentView addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(FitScale(10), FitScale(10), FitScale(30), FitScale(10)));
    }];
    
    @weakify(self)
    self.contentLab.attributedText = [AttributeMaker attributeMaker:^(AttributeMaker *maker) {
        @strongify(self)
        CGRect rect = CGRectMake(0, FitScale(5) - self.contentLab.font.lineHeight/2.0, FitScale(10), FitScale(10));
        UIImage *image = [UIImage imageNamed:@"cc_black_copy"];
        NSString *text = [NSString stringWithFormat:@"%@  ",self.scanResult];
        maker.text(text)
        .addImage(image,rect,text.length);
    }];
    
    self.contentLab.layer.cornerRadius = FitScale(5);
    self.contentLab.layer.masksToBounds = YES;
    
    [self.contentLab cc_tapHandle:^{
        @strongify(self)
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = self.scanResult;
        [MBProgressHUD showMessage:Localized(@"Copy Success")];
    }];
}

#pragma mark - get
- (CCEdgeLabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[CCEdgeLabel alloc] init];
        _contentLab.backgroundColor = CC_GRAY_BACKCOLOR;
        _contentLab.textColor = CC_GRAY_TEXTCOLOR;
        _contentLab.font = MediumFont(FitScale(12));
        _contentLab.edgeInsets = UIEdgeInsetsMake(FitScale(5), FitScale(5), FitScale(5), FitScale(5));
        _contentLab.numberOfLines = 0;
    }
    return _contentLab;
}

@end
