//
//  MLMChooseImageView.h
//  Live
//
//  Created by FTGJ on 2017/7/28.
//  Copyright © 2017年 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLMChooseImageView : UICollectionView

//最大选择图片
@property (nonatomic, assign) NSInteger max_Img;
@property (nonatomic, weak) UIViewController *parentVC;


@property (nonatomic, copy) void(^imagesChoose)(NSArray *images,NSArray *urls);


//初始images，可能是url或者传入的图片
@property (nonatomic, strong) NSArray *sourceArray;

//初始化
- (instancetype)initWithWidth:(CGFloat)viewWidth fromParentVC:(UIViewController *)parentVC columnNum:(NSInteger)columnNum cellSpace:(CGFloat)cellSpace;
- (instancetype)initWithWidth:(CGFloat)viewWidth fromParentVC:(UIViewController *)parentVC;


- (CGFloat)viewHeight;
+ (CGFloat)viewHeightWithSource:(NSInteger)sourceCount withMaxImg:(CGFloat)maxImg columnNum:(NSInteger)columnNum cellSpace:(CGFloat)cellSpace width:(CGFloat)width;


//选择图片的默认图
@property (nonatomic, strong) NSString *defaultImage;

@end
