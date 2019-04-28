//
//  AppDelegate.m
//  Karathen
//
//  Created by Karathen on 2018/7/9.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+RootViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <Bugly/Bugly.h>
#import "BaiduMobStat.h"
#import "CCAppInfo.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[CCDataManager dataManager] clearData];
    //蓝牙监控
    [[CCBlueTooth blueTooth] startMonitor];
    //根试图
    [self setAppWindows];
    [self setRootViewController];
    //键盘设置
    [self iqKeyBoardSet];
    [self adaptation];
    //网络链接监测
    [GLobalRealReachability startNotifier];
    //上传钱包地址
    if ([[CCDataManager dataManager] hadAccount]) {
        [[CCDataManager dataManager].activeAccount upLoadDevice];
    }
    //添加通知
    [self addNofity];
    //bugly
    [self setupBugly];
    //百度埋点
    [self setBaiduMobStat];
    
    return YES;
}


#pragma mark - addNotify
- (void)addNofity {
    @weakify(self)
    [CCNotificationCenter receiveAccountChangeObserver:self completion:^(BOOL add, NSString *accountID) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (add) {
                if ([CCDataManager dataManager].accounts.count == 1) {
                    [self setTabbarContoller];
                }
            } else {
                if ([CCDataManager dataManager].accounts.count == 0) {
                    [self setHomeWalletVC];
                }
            }
        });
    }];
}

#pragma mark - IQKeyBordSet
- (void)iqKeyBoardSet {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.enableAutoToolbar = NO;
    manager.shouldResignOnTouchOutside = YES;
}

- (void)adaptation {
    //适配iOS11
    if (@available(ios 11.0,*)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UITableView.appearance.estimatedRowHeight = 0.f;
        UITableView.appearance.estimatedSectionFooterHeight = 0.f;
        UITableView.appearance.estimatedSectionHeaderHeight = 0.f;
    }
}

#pragma mark - bugly
- (void)setupBugly {
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 1.5;
    config.channel = [CCAppInfo channelString];
    config.consolelogEnable = NO;
    config.viewControllerTrackingEnable = NO;
    [Bugly startWithAppId:BUGLY_APP_ID];
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"User: %@", [UIDevice currentDevice].name]];
    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"Process"];
}

#pragma mark - 百度埋点
- (void)setBaiduMobStat {
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.channelId = [CCAppInfo channelString];
    [statTracker startWithAppId:BAIDUMOBSTAT_APP_ID];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - InterfaceOrientation //应用支持的方向
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
