//
//  CCGradientView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCGradientView : UIView

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;

@property(nonatomic, strong) NSArray *colors;
@property(nonatomic, strong) NSArray<NSNumber *> *locations;

- (void)drawGradient;

@end
