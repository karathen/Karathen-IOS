//
//  CCImportWalletView.h
//  Karathen
//
//  Created by Karathen on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCScrollContentView.h"

@class CCImportWalletView;
@protocol CCImportWalletViewDelegate <NSObject>

@optional
- (void)createActionImportView:(CCImportWalletView *)importView;

@end

@interface CCImportWalletView : CCScrollContentView

@property (nonatomic, weak) id <CCImportWalletViewDelegate> importDelegate;
- (instancetype)initWithWalletType:(CCWalletType)walletType;

- (void)changeWalletInfo:(NSString *)walletInfo;

@end

@interface CCImportWalletTypeModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) CCImportType importType;
@property (nonatomic, strong) NSString *placeHolder;

- (instancetype)initWithType:(CCImportType)importType;

@end
