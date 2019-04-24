//
//  CCCopyAddressView.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCopyAddressView : UIView

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) UIButton *button;

@end
