//
//  CCHardwareListView.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/29.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTableView.h"
#import "CCBottomLineTableViewCell.h"

@class CCHardwareDevice;
@protocol CCHardwareListViewDelegate <NSObject>

@optional
- (void)connectDeviceSuccess:(NSInteger)saveDevice deviceName:(NSString *)deviceName;

@end


@interface CCHardwareListView : CCTableView

@property (nonatomic, weak) id<CCHardwareListViewDelegate> hardwareDelegate;
- (void)scannerHardware;

@end


@interface CCHardwareListCell : CCBottomLineTableViewCell

@property (nonatomic, strong) UIImageView *typeImgView;
@property (nonatomic, strong) UILabel *nameLab;

- (void)bindCellWithModel:(CCHardwareDevice *)device;

@end
