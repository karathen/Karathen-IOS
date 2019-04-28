//
//  CCHomeWalletView.h
//  Karathen
//
//  Created by Karathen on 2018/11/28.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCHomeWalletView;
@protocol CCHomeWalletViewDelegate <NSObject>

@optional
- (void)walletTypeChangeWithView:(CCHomeWalletView *)walletView;

@end

@interface CCHomeWalletView : UIView

@property (nonatomic, weak) id<CCHomeWalletViewDelegate> delegate;

@property (nonatomic, assign) CCWalletType walletType;

@end


@interface CCHomeWalletTypeModel : NSObject

@property (nonatomic, assign) CCWalletType walletType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *content;

- (instancetype)initWithWalletType:(CCWalletType)walletType;

@end
