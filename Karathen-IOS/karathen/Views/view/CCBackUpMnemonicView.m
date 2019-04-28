//
//  CCBackUpMnemonicView.m
//  Karathen
//
//  Created by Karathen on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBackUpMnemonicView.h"

@interface CCBackUpMnemonicView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSString *mnemonic;//助记词
@property (nonatomic, strong) NSMutableArray <CCBackUpMnemonicModel *> *mnemonicArray;//正序的助记词
@property (nonatomic, assign) CCBackUpMnemonicType type;


@property (nonatomic, strong) NSMutableArray <CCBackUpMnemonicModel *> *disOrderArray;//乱序的助记词，对应CCBackUpMnemonicTypeVerify

@property (nonatomic, strong) NSMutableArray <CCBackUpMnemonicModel *> *resultArray;//待比对的助记词，对应CCBackUpMnemonicTypeCancle


@end


@implementation CCBackUpMnemonicView

+ (CCBackUpMnemonicView *)backupViewWithMnemonic:(NSString *)mnemonic viewWidth:(CGFloat)viewWidth viewType:(CCBackUpMnemonicType)viewtype {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CCBackUpMnemonicView *backupView = [[CCBackUpMnemonicView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    backupView.mnemonic = mnemonic;
    backupView.type = viewtype;

    [backupView dealData];
    [backupView initViewWithViewWidth:viewWidth layout:layout];
    return backupView;
}

#pragma mark - initView
- (void)initViewWithViewWidth:(CGFloat)viewWidth layout:(UICollectionViewFlowLayout *)layout {
    NSInteger allCount = 0;
    if (self.type == CCBackUpMnemonicTypeCancle) {
        NSArray *mnemonics = [self.mnemonic componentsSeparatedByString:@" "];
        allCount = mnemonics.count;
    } else {
        allCount = self.mnemonicArray.count;
    }
    //列
    NSInteger column = 3;
    NSInteger row = allCount/column + (allCount%column == 0 ? 0 : 1);
    //上下间距
    CGFloat topSpace = FitScale(10);
    //itemSize
    CGFloat itemWidth = viewWidth/column;
    CGFloat itemHeight = FitScale(38);
    CGFloat viewHeight = itemHeight*row + 2*topSpace;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(topSpace, 0, topSpace, 0);
    
    self.viewSize = CGSizeMake(viewWidth, viewHeight);
    
    self.scrollEnabled = NO;
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[CCBackUpMnemonicCell class] forCellWithReuseIdentifier:@"CCBackUpMnemonicCell"];
}


- (void)dealData {
    if (self.type == CCBackUpMnemonicTypeCancle) {
        return;
    }
    self.mnemonicArray = [NSMutableArray array];
    NSArray *mnemonics = [self.mnemonic componentsSeparatedByString:@" "];
    for (NSInteger i = 0; i < mnemonics.count; i ++) {
        NSString *mnemonic = mnemonics[i];
        CCBackUpMnemonicModel *backupModel = [[CCBackUpMnemonicModel alloc] init];
        backupModel.mnemonic = mnemonic;
        backupModel.index = i;
        [self.mnemonicArray addObject:backupModel];
    }
    
    if (self.type == CCBackUpMnemonicTypeVerify) {
        self.disOrderArray = [self randomArrayWithArray:self.mnemonicArray];
    }
}

#pragma mark - 有序数组生成乱序数组
- (NSMutableArray *)randomArrayWithArray:(NSArray *)array {
    NSMutableArray *randomArray = [NSMutableArray arrayWithArray:array];
    NSInteger count = randomArray.count;
    while (count >= 1) {
        NSInteger index = arc4random()%count;
        [randomArray exchangeObjectAtIndex:count-1 withObjectAtIndex:index];
        count--;
    }
    return randomArray;
}

#pragma mark - 当前操作的数组
- (NSMutableArray *)currentArray {
    switch (self.type) {
        case CCBackUpMnemonicTypeCustom:
        {
            return self.mnemonicArray;
        }
            break;
        case CCBackUpMnemonicTypeCancle:
        {
            return self.resultArray;
        }
            break;
        case CCBackUpMnemonicTypeVerify:
        {
            return self.disOrderArray;
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - method
//CCBackUpMnemonicTypeCancle调用
- (void)addOrCancelModel:(CCBackUpMnemonicModel *)model {
    if (model.selected) {
        [self.resultArray addObject:model];
    } else {
        [self.resultArray removeObject:model];
    }
    [self reloadData];
}

- (BOOL)verifyMnemonic {
    NSArray *mnemonics = [self.mnemonic componentsSeparatedByString:@" "];
    if (self.resultArray.count != mnemonics.count) {
        return NO;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < self.resultArray.count; i ++) {
        CCBackUpMnemonicModel *model = self.resultArray[i];
        [result addObject:model.mnemonic];
    }
    NSString *resultMnemonic = [result componentsJoinedByString:@" "];
    
    return [resultMnemonic isEqualToString:self.mnemonic];
}

///CCBackUpMnemonicTypeVerify调用
- (void)selectedChangeModel:(CCBackUpMnemonicModel *)model {
    model.selected = !model.selected;
    [self reloadData];
}

#pragma mark - collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self currentArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentArray = [self currentArray];
    CCBackUpMnemonicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CCBackUpMnemonicCell" forIndexPath:indexPath];
    CCBackUpMnemonicModel *model = currentArray[indexPath.row];
    [cell bindCellWithModel:model withType:self.type];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type != CCBackUpMnemonicTypeCustom) {
        NSArray *currentArray = [self currentArray];
        CCBackUpMnemonicModel *model = currentArray[indexPath.row];
        if (self.type == CCBackUpMnemonicTypeCancle) {//选中后移除
            [self.resultArray removeObject:model];
            [self deleteItemsAtIndexPaths:@[indexPath]];
        } else if(self.type == CCBackUpMnemonicTypeVerify) {//选中后更改状态
            model.selected = !model.selected;
            [self reloadItemsAtIndexPaths:@[indexPath]];
        }
        if (model && self.backupDelegate && [self.backupDelegate respondsToSelector:@selector(backupView:selectModel:)]) {
            [self.backupDelegate backupView:self selectModel:model];
        }
    }
}

#pragma mark - get
- (NSMutableArray<CCBackUpMnemonicModel *> *)resultArray {
    if (!_resultArray) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

@end

@implementation CCBackUpMnemonicModel


@end

@interface CCBackUpMnemonicCell ()

@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, weak) CCBackUpMnemonicModel *model;

@end

@implementation CCBackUpMnemonicCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)bindCellWithModel:(CCBackUpMnemonicModel *)model withType:(CCBackUpMnemonicType)type {
    if (type == CCBackUpMnemonicTypeVerify) {
        self.contentLab.layer.cornerRadius = FitScale(3);
        self.contentLab.layer.masksToBounds = YES;
        if (model.selected) {
            self.contentLab.textColor = CC_BLACK_COLOR;
            self.contentLab.backgroundColor = CC_GRAY_BACKCOLOR;
        } else {
            self.contentLab.textColor = [UIColor whiteColor];
            self.contentLab.backgroundColor = CC_BTN_TITLE_COLOR;
        }
    } else {
        self.contentLab.backgroundColor = [UIColor clearColor];
        self.contentLab.textColor = RGB(0x28313b);
    }
    
    self.contentLab.text = model.mnemonic;
}

#pragma mark - createView
- (void)createView {
    [self.contentView addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(FitScale(1), FitScale(1), FitScale(1), FitScale(1)));
    }];
}

#pragma mark - get
- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.font = MediumFont(FitScale(13));
        _contentLab.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLab;
}

@end
