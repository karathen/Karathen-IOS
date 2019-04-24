//
//  CCWalletEditView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCWalletEditView;
@protocol CCWalletEditViewDelegate <NSObject>

@optional
- (void)textChangeInfoView:(CCWalletEditView *)infoView;

@end

@interface CCWalletEditView : UIView

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, weak) id<CCWalletEditViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *lineView;


- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeHolder;

//添加试图
- (void)createView;


@end
