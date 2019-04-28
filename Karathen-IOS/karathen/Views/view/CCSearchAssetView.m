//
//  CCSearchAssetView.m
//  Karathen
//
//  Created by Karathen on 2018/7/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCSearchAssetView.h"
#import "CCTokenInfoRequest.h"

@interface CCSearchAssetView () <UITableViewDelegate, UITableViewDataSource,CCSearchAssetCellDelegate>

@property (nonatomic, weak) CCWalletData *wallet;
@property (nonatomic, strong) CCTokenInfoRequest *searchRequest;
@property (nonatomic, strong) NSArray *resultAssets;

@end

@implementation CCSearchAssetView

+ (CCSearchAssetView *)searchViewWithWallet:(CCWalletData *)wallet {
    CCSearchAssetView *searchView = [[CCSearchAssetView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    searchView.wallet = wallet;
    [searchView initView];
    return searchView;
}

- (void)searchAsset:(NSString *)keywords {
    if (keywords.length == 0) {
        self.resultAssets = [NSArray array];
        [self reloadData];
        return;
    }
    if ([self.searchRequest isExecuting]) {
        [[YTKNetworkAgent sharedAgent] cancelRequest:self.searchRequest];
    }
    self.searchRequest.keyWord = [keywords deleteSpace];
    self.searchRequest.coinType = [CCDataManager coinKeyWithType:self.wallet.type];
    [self beginRefresh];
    @weakify(self)
    [self.searchRequest requestCompletion:^(NSArray<CCTokenInfoModel *> *result) {
        @strongify(self)
        [self endRefresh];
        self.resultAssets = [result copy];
        [self reloadData];
    }];
}

- (void)beginRefresh {
    if (!self.mj_header) {
        self.mj_header = [CCRefreshNormalHeader headerWithRefreshingBlock:nil];
    }
    [self.mj_header beginRefreshing];
    self.scrollEnabled = NO;
}

- (void)endRefresh {
    [self.mj_header endRefreshing];
    self.mj_header = nil;
    self.scrollEnabled =YES;
}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        self.resultAssets = nil;
        [self reloadData];
    }
}

#pragma mark - initView
- (void)initView {
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = 0;
    self.backgroundColor = [UIColor whiteColor];
    [self registerClass:[CCSearchAssetCell class] forCellReuseIdentifier:@"CCSearchAssetCell"];
}

#pragma mark - CCSearchAssetCellDelegate
- (void)addWithAssetCell:(CCSearchAssetCell *)cell {
    [self.wallet addAsset:cell.asset];
    [self reloadData];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultAssets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCSearchAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCSearchAssetCell"];
    cell.delegate = self;
    CCTokenInfoModel *assetModel = self.resultAssets[indexPath.row];
    [cell bindCellWithAsset:assetModel hadAddAsset:[self.wallet hadAddAsset:assetModel] walletData:self.wallet];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView endEdit];
    CCTokenInfoModel *assetModel = self.resultAssets[indexPath.row];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = assetModel.tokenAddress;
    [MBProgressHUD showMessage:Localized(@"Copy Success")];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FitScale(65);
}

#pragma mark - scrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [UIView endEdit];
}

#pragma makr - get
- (CCTokenInfoRequest *)searchRequest {
    if (!_searchRequest) {
        _searchRequest = [[CCTokenInfoRequest alloc] init];
    }
    return _searchRequest;
}

@end


@interface CCSearchAssetCell ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, weak) CCTokenInfoModel *asset;

@end

@implementation CCSearchAssetCell

- (void)bindCellWithAsset:(CCTokenInfoModel *)asset
              hadAddAsset:(CCAsset *)hadAddAsset
               walletData:(CCWalletData *)walletData {
    self.asset = asset;
    
    self.selectedBtn.selected = hadAddAsset;
    self.selectedBtn.userInteractionEnabled = !hadAddAsset;
    if (hadAddAsset) {
        self.selectedBtn.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        self.selectedBtn.layer.borderColor = CC_MAIN_COLOR.CGColor;
    }
    if (hadAddAsset) {
        self.nameLab.text = hadAddAsset.tokenSynbol;
        self.detailLab.text = hadAddAsset.tokenName;
        self.addressLab.text = hadAddAsset.tokenAddress;
        [walletData bindImageView:self.iconImgView asset:hadAddAsset];
    } else {
        self.nameLab.text = asset.tokenSynbol;
        self.detailLab.text = asset.tokenName;
        self.addressLab.text = asset.tokenAddress;
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:asset.tokenIcon] placeholderImage:[UIImage imageNamed:[walletData defaultIcon]]];
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
    
    [self.contentView addSubview:self.selectedBtn];
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-FitScale(18));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(FitScale(45), FitScale(25)));
    }];
    
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgView.mas_right).offset(FitScale(15));
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-FitScale(3));
    }];
    
    [self.contentView addSubview:self.detailLab];
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_right).offset(FitScale(10));
        make.centerY.equalTo(self.nameLab.mas_centerY);
        make.right.lessThanOrEqualTo(self.selectedBtn.mas_left).offset(FitScale(-20));
    }];
    

    
    [self.contentView addSubview:self.addressLab];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_left);
        make.top.equalTo(self.contentView.mas_centerY).offset(FitScale(3));
        make.right.lessThanOrEqualTo(self.selectedBtn.mas_left).offset(FitScale(-20));
    }];
    
    @weakify(self)
    [self.selectedBtn cc_tapHandle:^{
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(addWithAssetCell:)]) {
            [self.delegate addWithAssetCell:self];
        }
    }];
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
        _nameLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = RGB(0x90939b);
        _detailLab.font = MediumFont(FitScale(14));
        _detailLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _detailLab;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.textColor = CC_BLACK_COLOR;
        _addressLab.font = MediumFont(FitScale(12));
        _addressLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLab;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setTitle:Localized(@"Add") forState:UIControlStateNormal];
        [_selectedBtn setTitle:Localized(@"Added") forState:UIControlStateSelected];
        [_selectedBtn setTitleColor:CC_MAIN_COLOR forState:UIControlStateNormal];
        [_selectedBtn setTitleColor:CC_GRAY_TEXTCOLOR forState:UIControlStateSelected];
        _selectedBtn.titleLabel.font = MediumFont(FitScale(12));
        _selectedBtn.layer.cornerRadius = FitScale(4);
        _selectedBtn.layer.borderWidth = 1;
        _selectedBtn.layer.masksToBounds = YES;
    }
    return _selectedBtn;
}

@end
