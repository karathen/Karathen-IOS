//
//  CCHardwareListView.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/29.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCHardwareListView.h"
#import "CCHardwareScanner.h"
#import "MLMNoDataView.h"

@interface CCHardwareListView () <UITableViewDelegate,UITableViewDataSource,CCHardwareScannerDelegate>

@property (nonatomic, strong) CCHardwareScanner *scanner;

@end

@implementation CCHardwareListView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero style:UITableViewStylePlain]) {
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[CCHardwareListCell class] forCellReuseIdentifier:@"CCHardwareListCell"];
        
        [self addNotify];
    }
    return self;
}

- (void)addNotify {
    @weakify(self)
    [CCBlueTooth blueToothObserver:self stateChange:^(BOOL blueToothOpen) {
        @strongify(self)
        if (blueToothOpen) {
            [self scannerHardware];
        } else {
            [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
        }
    }];
}

#pragma mark - 扫描设备
- (void)scannerHardware {
    if ([CCBlueTooth blueTooth].blueToothOpen) {
        [self.scanner scanHardwareDevices];
    } else {
        [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
    }
}

#pragma mark - 连接设备
- (void)connectDevice:(NSString *)deviceName {
    if (![CCBlueTooth blueTooth].blueToothOpen) {
        [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCAlertView showLoadingMessage:Localized(@"Connecting...")];
    });
    @weakify(self)
    [[CCHardwareWallet hardwareWallet] connectDevice:deviceName completion:^(BOOL success, int errorCode, NSInteger saveDevice) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCAlertView hidenAlertLoading];
            if (success) {
                @strongify(self)
                if ([self.hardwareDelegate respondsToSelector:@selector(connectDeviceSuccess:deviceName:)]) {
                    [self.hardwareDelegate connectDeviceSuccess:saveDevice deviceName:deviceName];
                }
            } else {
                if ([CCBlueTooth blueTooth].blueToothOpen) {
                    [MBProgressHUD showMessage:Localized(@"Connection failed")];
                } else {
                    [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
                }
            }
        });
    }];
}

#pragma mark - CCHardwareScannerDelegate
//扫描设备变动
- (void)hardwareDevicesChangeWithScanner:(CCHardwareScanner *)scanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (scanner.devices.count > 0) {
            [CCAlertView hidenAlertLoadingForView:self.superview];
        }
        [self reloadData];
    });
}

//扫描设备失败
- (void)scanDeviceFailWithScanner:(CCHardwareScanner *)scanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCAlertView hidenAlertLoadingForView:self.superview];
        if ([CCBlueTooth blueTooth].blueToothOpen) {
            [MBProgressHUD showMessage:Localized(@"Searching device failed")];
        } else {
            [MBProgressHUD showMessage:Localized(@"Please turn on the Bluetooth")];
        }
    });
}

- (void)scanDeviceStartWithScanner:(CCHardwareScanner *)scanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCAlertView showLoadingMessage:Localized(@"Scanning...") inView:self.superview];
    });
}

//扫描结束
- (void)scanDeviceEndWithScanner:(CCHardwareScanner *)scanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCAlertView hidenAlertLoadingForView:self.superview];
        if (scanner.devices.count == 0) {
            [MBProgressHUD showMessage:Localized(@"Not found connectable device")];
        }
    });
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.scanner.devices.count;
    [MLMNoDataView customAddToView:self offsetY:FitScale(-40) hidden:count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCHardwareListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCHardwareListCell"];
    CCHardwareDevice *device = self.scanner.devices[indexPath.row];
    [cell bindCellWithModel:device];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCHardwareDevice *device = self.scanner.devices[indexPath.row];
    NSString *accountID = [[CCDataManager dataManager] accountIDWithDeviceName:device.peripheralName];
    CCAccountData *account = [[CCDataManager dataManager] accountWithAccountID:accountID];
    if (account) {
        [MBProgressHUD showMessage:Localized(@"This hardware wallet had existed")];
    } else {
        [self connectDevice:device.peripheralName];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FitScale(50);
}

#pragma mark - get
- (CCHardwareScanner *)scanner {
    if (!_scanner) {
        _scanner = [[CCHardwareScanner alloc] init];
        _scanner.delegate = self;
    }
    return _scanner;
}

@end


@implementation CCHardwareListCell

- (void)bindCellWithModel:(CCHardwareDevice *)device {
    self.nameLab.text = [device.peripheralName substringFromIndex:15];
}

#pragma mark - createView
- (void)createView {
    [super createView];
    [self.contentView addSubview:self.typeImgView];
    [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(FitScale(14));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeImgView.mas_right).offset(FitScale(10));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
}

#pragma mark - get
- (UIImageView *)typeImgView {
    if (!_typeImgView) {
        _typeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_hardware_icon"]];
    }
    return _typeImgView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.font = MediumFont(FitScale(13));
    }
    return _nameLab;
}


@end
