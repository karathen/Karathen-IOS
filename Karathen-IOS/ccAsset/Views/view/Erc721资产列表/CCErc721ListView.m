//
//  CCErc721ListView.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/13.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCErc721ListView.h"
#import "MLMNoDataView.h"
#import "CCTokenIdsRequest.h"
#import "CCErc721TokenInfoModel.h"

typedef NS_ENUM(NSInteger, CCErc721ListType) {
    CCErc721ListTypeCustom,//默认
    CCErc721ListTypeCK,//CK猫
};

@interface CCErc721ListView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, assign) CCErc721ListType listType;
@property (nonatomic, strong) CCTokenIdsRequest *tokenRequest;

@end

@implementation CCErc721ListView

- (instancetype)initWithAsset:(CCAsset *)asset walletData:(CCWalletData *)walletData {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:layout]) {
        self.asset = asset;
        self.walletData = walletData;
        self.listType = [self listTypeWithAsset:asset];
        [self initView];
    }
    return self;
}

- (CCErc721ListType)listTypeWithAsset:(CCAsset *)asset {
    CCErc721ListType type = CCErc721ListTypeCustom;
    if ([CCWalletData checkIsCryptoKittiesAsset:asset]) {
        type = CCErc721ListTypeCK;
    }
    return type;
}

#pragma mark - initView
- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    self.dataSource = self;
    
    NSString *cellClass = [self cellClass];
    [self registerClass:NSClassFromString(cellClass) forCellWithReuseIdentifier:cellClass];
    
    [self addMjHead];
    [self changeFooterWithHadMore:self.tokenRequest.hadMore];
    
    [self loadHead];
}

#pragma mark - request
- (void)addMjHead {
    @weakify(self)
    CCRefreshNormalHeader *mjHeader = [CCRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadHead];
    }];
    mjHeader.stateLabel.textColor = CC_BLACK_COLOR;
    mjHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.mj_header = mjHeader;
}

- (void)changeFooterWithHadMore:(BOOL)hadMore {
    if (self.tokenRequest.dataArray.count) {
        @weakify(self)
        self.mj_footer = [CCRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadFoot];
        }];
    } else {
        self.mj_footer = nil;
    }
}

- (void)loadHead {
    @weakify(self)
    [self.tokenRequest headRefreshBlock:^{
        @strongify(self)
        [self changeFooterWithHadMore:self.tokenRequest.hadMore];
        [self endRefreshWithHadMore:self.tokenRequest.hadMore];
    }];
}

- (void)loadFoot {
    @weakify(self)
    [self.tokenRequest footRefreshBlock:^{
        @strongify(self)
        [self endRefreshWithHadMore:self.tokenRequest.hadMore];
    }];
}

- (void)endRefreshWithHadMore:(BOOL)hadMore {
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshing];
    }
    if (hadMore) {
        [self.mj_footer endRefreshing];
    } else {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
    [self reloadData];
}

#pragma mark - 间隔
- (CGFloat)space {
    return FitScale(10);
}

- (CGFloat)itemWidth {
    return (SCREEN_WIDTH - 3*self.space)/2.0;
}

- (CGFloat)itemHeight {
    switch (self.listType) {
        case CCErc721ListTypeCK:
            return FitScale(180);
            break;
        default:
            break;
    }
    return FitScale(145);
}

- (NSString *)cellClass {
    switch (self.listType) {
        case CCErc721ListTypeCK:
            return @"CCErcCKListCell";
            break;
        default:
            break;
    }
    return @"CCErc721ListCell";
}

#pragma mark - collectionDelegate
-  (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.tokenRequest.dataArray.count;
    [MLMNoDataView customAddToView:self offsetY:FitScale(-40) hidden:count];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCErc721TokenInfoModel *model = self.tokenRequest.dataArray[indexPath.row];
    CCErc721ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellClass] forIndexPath:indexPath];
    [cell bindCellWithModel:model asset:self.asset walletData:self.walletData];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.itemWidth, self.itemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.space;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.space;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat space = self.space;
    return UIEdgeInsetsMake(space, space, space, space);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(listView:didSelectedModel:)]) {
        CCErc721TokenInfoModel *model = self.tokenRequest.dataArray[indexPath.row];
        [self.listDelegate listView:self didSelectedModel:model];
    }
}

#pragma mark - get
- (CCTokenIdsRequest *)tokenRequest {
    if (!_tokenRequest) {
        _tokenRequest = [[CCTokenIdsRequest alloc] init];
        _tokenRequest.address = self.walletData.address;
        _tokenRequest.tokenAddress = self.asset.tokenAddress;
    }
    return _tokenRequest;
}

@end

#pragma mark - erc721默认cell
@interface CCErc721ListCell ()

@property (nonatomic, strong) UIImageView *iconImgView;

@end

@implementation CCErc721ListCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)bindCellWithModel:(CCErc721TokenInfoModel *)model asset:(CCAsset *)asset walletData:(CCWalletData *)walletData {
    self.idLab.text = [NSString stringWithFormat:@"# %@",model.tokenId];
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.equalTo(self.contentView.mas_width).multipliedBy(.65);
    }];
    
    [self.contentView addSubview:self.idLab];
    [self.idLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImgView.mas_bottom).offset(FitScale(10));
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(12));
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-FitScale(12));
    }];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.shadowColor = CC_BTN_ENABLE_COLOR.CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0, FitScale(1.5));
    self.contentView.layer.shadowOpacity = .3;
    self.contentView.layer.cornerRadius = FitScale(5);
}

#pragma mark - get
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.backgroundColor = RGB(0xf3f9ff);
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconImgView setImage:[UIImage imageNamed:@"cc_721_placeholder"]];
    }
    return _iconImgView;
}

- (UILabel *)idLab {
    if (!_idLab) {
        _idLab = [[UILabel alloc] init];
        _idLab.textColor = CC_BLACK_COLOR;
        _idLab.font = MediumFont(FitScale(13));
        _idLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _idLab;
}

@end

#pragma mark - CK猫
@interface CCErcCKListCell ()

@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) UIImageView *geneImgView;
@property (nonatomic, strong) UILabel *geneLab;

@property (nonatomic, strong) UIImageView *speedImgView;
@property (nonatomic, strong) UILabel *speedLab;

@end

@implementation CCErcCKListCell

- (void)bindCellWithModel:(CCErc721TokenInfoModel *)model asset:(CCAsset *)asset walletData:(CCWalletData *)walletData {
    [super bindCellWithModel:model asset:asset walletData:walletData];
    NSString *urlString = [model tokenIconWithAsset:asset];
    
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"cc_721_placeholder"]];
    
    self.geneLab.text = [model ckGeneration];
    self.speedLab.text = [model ckSpeed];
}

- (void)createView {
    [super createView];
    
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.idLab.mas_left);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.idLab.mas_bottom).offset(FitScale(6));
    }];
    
    [self.contentView addSubview:self.geneImgView];
    [self.geneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.idLab.mas_left);
        make.top.equalTo(self.lineView.mas_bottom).offset(FitScale(7));
    }];
    
    [self.contentView addSubview:self.geneLab];
    [self.geneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.geneImgView.mas_right).offset(FitScale(5));
        make.centerY.equalTo(self.geneImgView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.speedImgView];
    [self.speedImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.geneLab.mas_right).offset(FitScale(8));
        make.centerY.equalTo(self.geneImgView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.speedLab];
    [self.speedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.speedImgView.mas_right).offset(FitScale(5));
        make.centerY.equalTo(self.geneImgView.mas_centerY);
        make.right.lessThanOrEqualTo(self.lineView.mas_right);
    }];
}

- (UIImageView *)lineView {
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_dash_line"]];
    }
    return _lineView;
}

- (UIImageView *)geneImgView {
    if (!_geneImgView) {
        _geneImgView = [[UIImageView alloc] init];
        [_geneImgView setImage:[UIImage imageNamed:@"cc_ck_gene"]];
    }
    return _geneImgView;
}

- (UILabel *)geneLab {
    if (!_geneLab) {
        _geneLab = [[UILabel alloc] init];
        _geneLab.textColor = CC_GRAY_TEXTCOLOR;
        _geneLab.font = MediumFont(FitScale(12));
    }
    return _geneLab;
}

- (UIImageView *)speedImgView {
    if (!_speedImgView) {
        _speedImgView = [[UIImageView alloc] init];
        [_speedImgView setImage:[UIImage imageNamed:@"cc_ck_speed"]];
    }
    return _speedImgView;
}

- (UILabel *)speedLab {
    if (!_speedLab) {
        _speedLab = [[UILabel alloc] init];
        _speedLab.textColor = CC_GRAY_TEXTCOLOR;
        _speedLab.font = MediumFont(FitScale(12));
    }
    return _speedLab;
}

@end
