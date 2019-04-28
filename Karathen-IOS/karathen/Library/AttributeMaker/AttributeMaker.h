//
//  AttributeMaker.h
//  FuTangLiveDemo
//
//  Created by my on 16/6/4.
//  Copyright © 2016年 MS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AttributeMaker : NSObject

/**
 * 富文本
 */
@property (nonatomic) NSMutableAttributedString *attributeStr;

+ (NSMutableAttributedString *)attributeMaker:(void(^)(AttributeMaker *maker))attriMaker;

/**
 * 重要
 */
- (AttributeMaker *(^)(NSString *))text;
- (AttributeMaker *(^)(NSString *))textChange;
- (AttributeMaker *(^)(NSRange))range;


/**
 * 添加NSString
 */
- (AttributeMaker *(^)(NSString *))appendString;

/**
 * 添加NSAttributedString
 */
- (AttributeMaker *(^)(NSAttributedString *))appendAttribute;


/**
 * 改变颜色
 */
- (AttributeMaker *(^)(UIColor *))textColor;

/**
 * 添加链接
 */
- (AttributeMaker *(^)(NSString *))url;

/**
 * 段落
 */
- (AttributeMaker *(^)(NSParagraphStyle*))paragraph;


/**
 * 字体设置
 */
- (AttributeMaker *(^)(UIFont *))textFont;

/**
 * 字体背景色
 */
- (AttributeMaker *(^)(UIColor *))textBackColor;

/**
 * 改变字体间距
 */
- (AttributeMaker *(^)(NSInteger))space;

/**
 * 连字符,0 1
 */
- (AttributeMaker *(^)(NSInteger))ligature;


/**
 * 设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
 */
- (AttributeMaker *(^)(CGFloat))lineOffset;

/**
 * 添加下划线
 */
- (AttributeMaker *(^)(NSUnderlineStyle))underlineStyle;

/**
 * 下划线颜色
 */
- (AttributeMaker *(^)(UIColor *))underlineColor;

/**
 * 添加删除线
 */
- (AttributeMaker *(^)(NSUnderlineStyle))throughStyle;
/**
 * 删除线颜色
 */
- (AttributeMaker *(^)(UIColor *))throughColor;


/**
 * 单独设置不好使,阴影
 * NSVerticalGlyphFormAttributeName，NSObliquenessAttributeName，NSExpansionAttributeName这三个配合使用
 
 */
- (AttributeMaker *(^)(CGFloat,UIColor*,CGSize))shadow;

/**
 * 字体倾斜
 */
- (AttributeMaker *(^)(CGFloat))obliqueness;

/**
 * 文字扁平化
 */
- (AttributeMaker *(^)(CGFloat))expansion;


/**
 * 描边
 * 负值填充效果，正值中空效果
 */
- (AttributeMaker *(^)(UIColor*,CGFloat))stroke;

/**
 * 添加图片
 */
- (AttributeMaker *(^)(UIImage*,CGRect,NSInteger))addImage;


/**
 * 插入文字
 */
- (AttributeMaker *(^)(NSString *,NSInteger))addString;


////添加图片2
//- (AttributeMaker *)setImage:(UIImage *)image imageBounds:(CGRect)imageBounds atIndex:(NSInteger)index;

- (CGSize)attributeSizeWith:(CGSize)size;

@end
