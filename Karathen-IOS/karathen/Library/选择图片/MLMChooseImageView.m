//
//  MLMChooseImageView.m
//  Live
//
//  Created by FTGJ on 2017/7/28.
//  Copyright © 2017年 Zego. All rights reserved.
//

#import "MLMChooseImageView.h"
#import "MLMChooseImgCell.h"
#import "TZImagePickerController.h"

#define COLUMN_NUM 3
#define CELL_SPACE 15

@interface MLMChooseImageView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TZImagePickerControllerDelegate>

///图片数组
@property (nonatomic, strong) NSMutableArray *sourceImages;
///urls数组
@property (nonatomic, strong) NSMutableArray *sourceUrls;

@property (nonatomic, assign) NSInteger columnNum;
@property (nonatomic, assign) CGFloat cellSpace;


@end


@implementation MLMChooseImageView

- (instancetype)initWithWidth:(CGFloat)viewWidth fromParentVC:(UIViewController *)parentVC columnNum:(NSInteger)columnNum cellSpace:(CGFloat)cellSpace {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(cellSpace, cellSpace, cellSpace, cellSpace);
    CGFloat width = (viewWidth - (columnNum + 1)*cellSpace)/columnNum;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = cellSpace;
    layout.minimumInteritemSpacing = cellSpace;
    if (self = [super initWithFrame:CGRectMake(0, 0, viewWidth, width+2*cellSpace) collectionViewLayout:layout]) {
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.columnNum = columnNum;
        self.cellSpace = cellSpace;
        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        [self registerNib:[UINib nibWithNibName:@"MLMChooseImgCell" bundle:nil] forCellWithReuseIdentifier:@"MLMChooseImgCell"];
        
        self.parentVC = parentVC;
        
        [self initView];
    }
    return self;
}

- (instancetype)initWithWidth:(CGFloat)viewWidth fromParentVC:(UIViewController *)parentVC {
    return [self initWithWidth:viewWidth fromParentVC:parentVC columnNum:COLUMN_NUM cellSpace:CELL_SPACE];
}

- (void)initView {
    self.max_Img = 9;
}


#pragma mark - set&get
- (NSMutableArray *)sourceImages {
    if (!_sourceImages) {
        _sourceImages = [NSMutableArray array];
    }
    return _sourceImages;
}

- (NSMutableArray *)sourceUrls {
    if (!_sourceUrls) {
        _sourceUrls = [NSMutableArray array];
    }
    return _sourceUrls;
}

- (void)setSourceArray:(NSArray *)sourceArray {
    _sourceArray = sourceArray;
    [self.sourceImages removeAllObjects];
    [self.sourceUrls removeAllObjects];
    
    BOOL change = NO;
    //处理
    for (id image in sourceArray) {
        if ([image isKindOfClass:[UIImage class]]) {
            change = YES;
            [self.sourceImages addObject:image];
        } else if ([image isKindOfClass:[NSString class]]){
            change = YES;
            [self.sourceUrls addObject:image];
        } else {
            NSAssert(YES, @"数组只能是url或者UIImage");
        }
    }
    [self imagesChange];
    [self reloadData];
}

#pragma mark - dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger row = MIN(_max_Img, self.sourceImages.count+self.sourceUrls.count+1);
    return row;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MLMChooseImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MLMChooseImgCell" forIndexPath:indexPath];
    if (indexPath.row < self.sourceUrls.count) {
        NSString *url = self.sourceUrls[indexPath.row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:url]];
        cell.deleteBtn.hidden = NO;
    } else if (indexPath.row < (self.sourceUrls.count + self.sourceImages.count)) {
        [cell.imgView setImage:self.sourceImages[indexPath.row-self.sourceUrls.count]];
        cell.deleteBtn.hidden = NO;
    } else {
        [cell.imgView setImage:[UIImage imageNamed:self.defaultImage?:@"add_tianjia"]];
        cell.deleteBtn.hidden = YES;
    }
    @weakify(self)
    [cell.deleteBtn cc_tapHandle:^{
        @strongify(self)
        if (indexPath.row < self.sourceUrls.count) {
            [self.sourceUrls removeObjectAtIndex:indexPath.row];
        } else if (indexPath.row < (self.sourceUrls.count + self.sourceImages.count)) {
            [self.sourceImages removeObjectAtIndex:indexPath.row-self.sourceUrls.count];
        }
        [self imagesChange];
    }];
    return cell;
}


#pragma mark - delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < (self.sourceImages.count + self.sourceUrls.count)) {
        [self showImage:indexPath.row];
    } else {
        [self addImage];
    }
}

#pragma mark  - addImage
- (void)addImage {
//    @weakify(self)
//    [self.photoTool choosePhotoWithMax:self.max_Img-self.sourceImages.count-self.sourceUrls.count finishChoose:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//        @strongify(self)
//        [self.sourceImages addObjectsFromArray:photos];
//        [self imagesChange];
//    } takePhotoCompletion:^(UIImage *image) {
//        @strongify(self)
//        [self.sourceImages addObject:image];
//        [self imagesChange];
//    } fromVC:self.parentVC];
}

#pragma mark - method
- (void)imagesChange {
    if (self.imagesChoose) {
        self.imagesChoose(self.sourceImages,self.sourceUrls);
    }
}

- (CGFloat)viewHeight {
    return [MLMChooseImageView viewHeightWithSource:(self.sourceImages.count + self.sourceUrls.count) withMaxImg:_max_Img columnNum:self.columnNum cellSpace:self.cellSpace width:self.cc_width];
}

+ (CGFloat)viewHeightWithSource:(NSInteger)sourceCount withMaxImg:(CGFloat)maxImg columnNum:(NSInteger)columnNum cellSpace:(CGFloat)cellSpace width:(CGFloat)width{
    NSInteger count = MIN(maxImg, sourceCount+1);
    NSInteger rows = MAX(1, (NSInteger)(count/columnNum)  + (count%columnNum==0?0:1));
    CGFloat cell_width = (width - (columnNum + 1)*cellSpace)/columnNum;
    CGFloat height = rows*cell_width + (rows+1)*cellSpace;
    return height;
}

#pragma mark - showImage
- (void)showImage:(NSInteger)index {
    
}


@end
