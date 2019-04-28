//
//  CCGuideView.m
//  Karathen
//
//  Created by Karathen on 2018/9/11.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCGuideView.h"
#import "TYPageControl.h"

@interface CCGuideView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray <CCGuideSingleView *> *viewArray;

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSArray *icons;

@end


@implementation CCGuideView

- (instancetype)initWithIcons:(NSArray *)icons contents:(NSArray *)contents {
    if (self = [super init]) {
        self.contents = contents;
        self.icons = icons;
        [self createView];
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    self.scrollView.bounces = self.icons.count > 1;
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.mas_equalTo(self.icons.count * SCREEN_WIDTH);
    }];
    
    for (NSInteger i = 0; i < self.icons.count; i ++) {
        CCGuideSingleView *singView = [[CCGuideSingleView alloc] initWithContent:self.contents[i] image:self.icons[i]];
        [self.contentView addSubview:singView];
        [singView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(i*SCREEN_WIDTH);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.lessThanOrEqualTo(self.contentView.mas_bottom);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
    }
    
    [self layoutIfNeeded];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.scrollView.contentSize.height);
    }];
}

- (void)scrollToIndex:(NSInteger)index animation:(BOOL)animation {
    self.page = index;
    [self.scrollView setContentOffset:CGPointMake(index*SCREEN_WIDTH, 0) animated:YES];
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scale = scrollView.contentOffset.x/scrollView.contentSize.width;
    if ([self.delegate respondsToSelector:@selector(scrollScale:)]) {
        [self.delegate scrollScale:scale];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.page = scrollView.contentOffset.x/SCREEN_WIDTH;
    if ([self.delegate respondsToSelector:@selector(scrollToIndex:)]) {
        [self.delegate scrollToIndex:self.page];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.page = scrollView.contentOffset.x/SCREEN_WIDTH;
    if ([self.delegate respondsToSelector:@selector(scrollToIndex:)]) {
        [self.delegate scrollToIndex:self.page];
    }
}

#pragma mark - get
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end

@interface CCGuideSingleView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *contentLab;

@end

@implementation CCGuideSingleView

- (instancetype)initWithContent:(NSString *)content image:(NSString *)image {
    if (self = [super init]) {
        UIImage *iconImg = [UIImage imageNamed:image];
        CGFloat height = FitScale(180);
        CGFloat width = iconImg.size.width*height/iconImg.size.height;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.centerX.equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];

        [self addSubview:self.contentLab];
        [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(FitScale(30));
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.imageView.mas_bottom).offset(FitScale(30));
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        self.contentLab.text = content;
        [self.imageView setImage:iconImg];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textColor = RGB(0x7c7c7c);
        _contentLab.font = MediumFont(FitScale(13));
        _contentLab.textAlignment = NSTextAlignmentCenter;
        _contentLab.numberOfLines = 0;
    }
    return _contentLab;
}

@end
