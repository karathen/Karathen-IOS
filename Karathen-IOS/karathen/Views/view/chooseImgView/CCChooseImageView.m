//
//  CCChooseImageView.m
//  Karathen
//
//  Created by Karathen on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCChooseImageView.h"

@interface CCChooseImageView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger maxChoose;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) NSInteger columnNum;

@property (nonatomic, strong) NSMutableArray <CCChooseImageSingle *> *singleArray;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation CCChooseImageView

- (instancetype)initWithTitle:(NSString *)title
                    maxChoose:(NSInteger)maxChoose
                    viewWidth:(CGFloat)viewWidth
                    columnNum:(NSInteger)columnNum {
    if (self = [super init]) {
        self.title = title;
        self.viewWidth = viewWidth;
        self.maxChoose = maxChoose;
        self.columnNum = columnNum;
        self.backgroundColor = [UIColor whiteColor];
        
        self.titleLab.text = title;
        [self addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(FitScale(17));
            make.top.equalTo(self.mas_top).offset(FitScale(19));
            make.right.lessThanOrEqualTo(self.mas_right).offset(FitScale(-10));
        }];
        
        [self reloadData];
    }
    return self;
}


#pragma mark - reloadData
- (void)reloadData {    
    [self.singleArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //
    CGFloat space = FitScale(10);
    //
    CGFloat singleWidth = (self.viewWidth - (self.columnNum + 1)*space)/self.columnNum;

    //创建个数
    NSInteger count = MIN(self.imageArray.count + 1, self.maxChoose);
    for (NSInteger i = 0 ; i < count; i ++) {
        //当前第几行
        NSInteger row = i/self.columnNum;
        //当前第几列
        NSInteger colum = i%self.columnNum;
        CCChooseImageSingle *singleView;
        if (self.singleArray.count > i) {
            singleView = self.singleArray[i];
        } else {
            singleView = [[CCChooseImageSingle alloc] init];
            [self.singleArray addObject:singleView];
        }
        @weakify(self)
        [singleView cc_tapHandle:^{
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(chooseImageWithView:imageIndex:)]) {
                [self.delegate chooseImageWithView:self imageIndex:i];
            }
        }];
        
        [singleView.closeView cc_tapHandle:^{
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(deleteImageWithView:imageIndex:)]) {
                [self.delegate deleteImageWithView:self imageIndex:i];
            }
        }];
        
        UIImage *image;
        if (self.imageArray.count > i) {
            image = self.imageArray[i];
        }
        [singleView bindWithImage:image];
        
        [self addSubview:singleView];
        [singleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(colum*(singleWidth + space) + space);
            make.top.equalTo(self.titleLab.mas_bottom).offset(row*(singleWidth + space) + space);
            make.size.mas_equalTo(CGSizeMake(singleWidth, singleWidth));
            if (i == count-1) {
                make.bottom.equalTo(self.mas_bottom).offset(-space);
            }
        }];
    }
}


#pragma mark - get
- (NSMutableArray<CCChooseImageSingle *> *)singleArray {
    if (!_singleArray) {
        _singleArray = [NSMutableArray array];
    }
    return _singleArray;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = MediumFont(FitScale(14));
        _titleLab.textColor = CC_BLACK_COLOR;
    }
    return _titleLab;
}

@end



@interface CCChooseImageSingle ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CCChooseImageSingle

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.closeView];
        [self.closeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.size.mas_equalTo(CGSizeMake(FitScale(20), FitScale(20)));
        }];
    }
    return self;
}

- (void)bindWithImage:(UIImage *)image {
    if (image) {
        [self.imageView setImage:image];
        self.closeView.hidden = NO;
    } else {
        [self.imageView setImage:[UIImage imageNamed:@"cc_image_add"]];
        self.closeView.hidden = YES;
    }
}

#pragma mark - get
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)closeView {
    if (!_closeView) {
        _closeView = [[UIImageView alloc] init];
        [_closeView setImage:[UIImage imageNamed:@"cc_image_delete"]];
    }
    return _closeView;
}

@end
