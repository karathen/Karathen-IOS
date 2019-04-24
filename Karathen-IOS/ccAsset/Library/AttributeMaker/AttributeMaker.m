//
//  AttributeMaker.m
//  FuTangLiveDemo
//
//  Created by my on 16/6/4.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "AttributeMaker.h"

@interface AttributeMaker ()

@property (nonatomic) NSRange changeRange;

/**
 * 原text
 */
@property (nonatomic, copy) NSString *textCustom;

@end

@implementation AttributeMaker

+ (NSMutableAttributedString *)attributeMaker:(void(^)(AttributeMaker *maker))attriMaker {
    AttributeMaker *maker = [[AttributeMaker alloc] init];
    if (attriMaker) {
        attriMaker(maker);
    }
    return maker.attributeStr?maker.attributeStr:[[NSMutableAttributedString alloc] initWithString:@""];
}

- (AttributeMaker *(^)(NSString *))text {
    return ^(NSString *text) {
        self.textCustom = text?:@"";
        self.attributeStr = [[NSMutableAttributedString alloc] initWithString:text];
        
        self.changeRange = NSMakeRange(0, text.length);
        return self;
    };
}

- (AttributeMaker *(^)(NSString *))textChange {
    return ^(NSString *textChange) {
        self.changeRange = [self.textCustom rangeOfString:textChange];
        return self;
    };
}

- (AttributeMaker *(^)(NSRange))range {
    return ^(NSRange range) {
        self.changeRange = range;
        return self;
    };
}



//添加NSString
- (AttributeMaker *(^)(NSString *))appendString {
    return ^(NSString *append) {
        [self.attributeStr appendAttributedString:[[NSAttributedString alloc] initWithString:append]];
        return self;
    };
}

//添加NSAttributedString
- (AttributeMaker *(^)(NSAttributedString *))appendAttribute {
    return ^(NSAttributedString *append) {
        [self.attributeStr appendAttributedString:append];
        return self;
    };
}


//改变颜色
- (AttributeMaker *(^)(UIColor *))textColor {
    return ^(UIColor *textColor) {
        [self.attributeStr addAttributes:@{NSForegroundColorAttributeName:textColor} range:self.changeRange];
        return self;
    };
}


//添加链接
- (AttributeMaker *(^)(NSString *))url {
    return ^(NSString *url) {
        [self.attributeStr addAttributes:@{NSLinkAttributeName:url} range:self.changeRange];
        return self;
    };
}


//段落
- (AttributeMaker *(^)(NSParagraphStyle*))paragraph {
    return ^(NSParagraphStyle *paragraph) {
        //        //行间距
        //        paragraph.lineSpacing = 10;
        //        //段落间距
        //        paragraph.paragraphSpacing = 20;
        //        //对齐方式
        //        paragraph.alignment = NSTextAlignmentLeft;
        //        //指定段落开始的缩进像素
        //        paragraph.firstLineHeadIndent = 30;
        //        //调整全部文字的缩进像素
        //        paragraph.headIndent = 10;
        [self.attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:self.changeRange];
        return self;
    };
}


//字体设置
- (AttributeMaker *(^)(UIFont *))textFont {
    return ^(UIFont *textFont) {
        [self.attributeStr addAttributes:@{NSFontAttributeName:textFont} range:self.changeRange];
        return self;
    };
}


//字体背景色
- (AttributeMaker *(^)(UIColor *))textBackColor {
    return ^(UIColor *textBackColor) {
        [self.attributeStr addAttributes:@{NSBackgroundColorAttributeName:textBackColor} range:self.changeRange];
        return self;
    };
}

//改变字体间距,正数变宽，负数变窄
- (AttributeMaker *(^)(NSInteger))space {
    return ^(NSInteger space) {
        [self.attributeStr addAttribute:NSKernAttributeName value:@(space) range:self.changeRange];
        return self;
    };
}

//连字符
- (AttributeMaker *(^)(NSInteger))ligature {
    return ^(NSInteger ligature) {
        [self.attributeStr addAttribute:NSLigatureAttributeName value:@(ligature) range:self.changeRange];
        return self;
    };
}



//添加下划线
- (AttributeMaker *(^)(NSUnderlineStyle))underlineStyle {
    return ^(NSUnderlineStyle underlineStyle) {
        [self.attributeStr addAttribute:NSUnderlineStyleAttributeName value:@(underlineStyle) range:self.changeRange];
        return self;
    };
}

//下划线颜色
- (AttributeMaker *(^)(UIColor *))underlineColor {
    return ^(UIColor *underlineColor) {
        [self.attributeStr addAttribute:NSUnderlineColorAttributeName value:underlineColor range:self.changeRange];
        return self;
    };
}

//添加删除线
//取值为 0 - 7时，效果为单实线，随着值得增加，单实线逐渐变粗，取值为 9 - 15时，效果为双实线，取值越大，双实线越粗
- (AttributeMaker *(^)(NSUnderlineStyle))throughStyle {
    return ^(NSUnderlineStyle underlineStyle) {
        [self.attributeStr addAttribute:NSStrikethroughStyleAttributeName value:@(underlineStyle) range:self.changeRange];
        //10.3之后
        [self.attributeStr addAttribute:NSBaselineOffsetAttributeName value:@(underlineStyle) range:self.changeRange];
        return self;
    };
}

//删除线颜色
- (AttributeMaker *(^)(UIColor *))throughColor {
    return ^(UIColor *underlineColor) {
        [self.attributeStr addAttribute:NSStrikethroughColorAttributeName value:underlineColor range:self.changeRange];
        return self;
    };
}



/**
 * 单独设置不好使,阴影
 * NSVerticalGlyphFormAttributeName，NSObliquenessAttributeName，NSExpansionAttributeName这三个配合使用
 
 */
- (AttributeMaker *(^)(CGFloat,UIColor*,CGSize))shadow {
    return ^(CGFloat blurRadius,UIColor *color,CGSize offSet) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = blurRadius;
        shadow.shadowColor = color;
        shadow.shadowOffset = offSet;
        
        
        [self.attributeStr addAttribute:NSShadowAttributeName value:shadow range:self.changeRange];
        //横竖版
        [self.attributeStr addAttribute:NSVerticalGlyphFormAttributeName value:@(0) range:self.changeRange];
        
        return self;
    };
}

//设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
- (AttributeMaker *(^)(CGFloat))lineOffset {
    return ^(CGFloat number) {
        [self.attributeStr addAttribute:NSBaselineOffsetAttributeName value:@(number) range:self.changeRange];
        return self;
    };
}

//字体倾斜 0-1
- (AttributeMaker *(^)(CGFloat))obliqueness {
    return ^(CGFloat number) {
        [self.attributeStr addAttribute:NSObliquenessAttributeName value:@(number) range:self.changeRange];
        return self;
    };
}

//文字扁平化
- (AttributeMaker *(^)(CGFloat))expansion {
    return ^(CGFloat number) {
        [self.attributeStr addAttribute:NSExpansionAttributeName value:@(number) range:self.changeRange];
        return self;
    };
}


//描边,正数空心  负数实心
- (AttributeMaker *(^)(UIColor*strokeColor,CGFloat strokeWidth))stroke {
    return ^(UIColor *strokeColor,CGFloat strokeWidth) {
        [self.attributeStr addAttribute:NSStrokeColorAttributeName value:strokeColor range:self.changeRange];
        [self.attributeStr addAttribute:NSStrokeWidthAttributeName value:@(strokeWidth) range:self.changeRange];
        return self;
    };
}

//添加图片
- (AttributeMaker *(^)(UIImage*,CGRect,NSInteger))addImage {
    return ^(UIImage *image, CGRect imageBounds, NSInteger index) {
        return [self setImage:image imageBounds:imageBounds atIndex:index];
    };
}

//添加图片
- (AttributeMaker *)setImage:(UIImage *)image imageBounds:(CGRect)imageBounds atIndex:(NSInteger)index {
    
    //添加图片
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = image;
    attch.bounds = imageBounds;
    //带有图片的富文本
    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attch];
    
    [self.attributeStr insertAttributedString:imageStr atIndex:index];
    return self;
}


- (AttributeMaker *(^)(NSString *,NSInteger))addString {
    return ^(NSString *string, NSInteger index) {
        return [self addString:string atIndex:index];
    };
}


- (AttributeMaker *)addString:(NSString *)string atIndex:(NSInteger)index {
    
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:string];
    [self.attributeStr insertAttributedString:attribute atIndex:index];
    return self;
}





//size
- (CGSize)attributeSizeWith:(CGSize)size {
    return [self.attributeStr boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}


@end
