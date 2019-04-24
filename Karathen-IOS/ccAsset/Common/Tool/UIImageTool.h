//
//  UIImageTool.h
//  BaseProject
//
//  Created by my on 16/4/20.
//  Copyright © 2016年 base. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageTool : NSObject

///生成图片
+ (UIImage *)createImageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size;

+ (NSData *)compressDataWithImage:(UIImage *)image;

@end
