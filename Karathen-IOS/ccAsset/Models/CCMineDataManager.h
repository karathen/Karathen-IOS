//
//  CCMineDataManager.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CCMineDataType) {
    CCMineDataTypeUnit,//货币单位
    CCMineDataTypeLanguage,//语言设置
    CCMineDataTypeHelp,//帮助中心
    CCMineDataTypeContactService,//技术支持
    CCMineDataTypeAboutUs,//关于我们
};


@interface CCMineDataManager : NSObject

+ (NSArray *)dataArray;


@end


@interface CCMineDataModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) CCMineDataType type;

@end
