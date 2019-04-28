//
//  CCGradientView.m
//  Karathen
//
//  Created by Karathen on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCGradientView.h"

@implementation CCGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)drawGradient {
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    layer.startPoint = self.startPoint;
    layer.endPoint = self.endPoint;
    layer.colors = self.colors;
    layer.locations = self.locations;
}


@end
