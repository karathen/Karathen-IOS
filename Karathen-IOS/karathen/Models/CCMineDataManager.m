//
//  CCMineDataManager.m
//  Karathen
//
//  Created by Karathen on 2018/9/6.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCMineDataManager.h"

@implementation CCMineDataManager


#pragma mark - 数据
+ (NSArray *)dataArray {
    return @[
             [CCMineDataManager dataModelWithType:CCMineDataTypeUnit],
             [CCMineDataManager dataModelWithType:CCMineDataTypeLanguage],
//             [CCMineDataManager dataModelWithType:CCMineDataTypeHelp],
             [CCMineDataManager dataModelWithType:CCMineDataTypeContactService],
             [CCMineDataManager dataModelWithType:CCMineDataTypeAboutUs],
             ];
}

#pragma mark - CCMineData
+ (CCMineDataModel *)dataModelWithType:(CCMineDataType)type {
    CCMineDataModel *model = [[CCMineDataModel alloc] init];
    model.type = type;
    switch (type) {
        case CCMineDataTypeUnit:
        {
            model.title = Localized(@"Currency Unit");
            model.icon = @"cc_mine_unit";
        }
            break;
        case CCMineDataTypeLanguage:
        {
            model.title = Localized(@"Language");
            model.icon = @"cc_mine_language";
        }
            break;
        case CCMineDataTypeHelp:
        {
            model.title = Localized(@"Suport");
            model.icon = @"cc_mine_suport";
        }
            break;
        case CCMineDataTypeContactService:
        {
            model.title = Localized(@"Technical Support");
            model.icon = @"cc_mine_technicalSupport";
        }
            break;
        case CCMineDataTypeAboutUs:
        {
            model.title = Localized(@"About");
            model.icon = @"cc_mine_about";
        }
            break;
        default:
            break;
    }
    return model;
}

@end


@implementation CCMineDataModel



@end
