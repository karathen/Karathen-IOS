//
//  CCAboutUsManager.m
//  Karathen
//
//  Created by Karathen on 2018/9/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCAboutUsManager.h"

@implementation CCAboutUsManager

#pragma mark - 数据
+ (NSArray *)dataArray {
    return @[
             [CCAboutUsManager dataModelWithType:CCAboutUsTypeService],
             [CCAboutUsManager dataModelWithType:CCAboutUsTypePrivacy],
//             [CCAboutUsManager dataModelWithType:CCAboutUsTypeUpdate],
             [CCAboutUsManager dataModelWithType:CCAboutUsTypeContact],
             ];
}

#pragma mark - CCMineData
+ (CCAboutUsModel *)dataModelWithType:(CCAboutUsType)type {
    CCAboutUsModel *model = [[CCAboutUsModel alloc] init];
    model.type = type;
    switch (type) {
        case CCAboutUsTypeService:
        {
            model.title = Localized(@"Terms of Service");
            model.icon = @"cc_aboutus_service";
        }
            break;
        case CCAboutUsTypePrivacy:
        {
            model.title = Localized(@"Privacy Policy");
            model.icon = @"cc_aboutus_privacy";
        }
            break;
        case CCAboutUsTypeUpdate:
        {
            model.title = Localized(@"Check for updates");
            model.icon = @"cc_aboutus_update";
        }
            break;
        case CCAboutUsTypeContact:
        {
            model.title = Localized(@"Contact us");
            model.icon = @"cc_aboutus_contact";
        }
            break;
        default:
            break;
    }
    return model;
}

@end

@implementation CCAboutUsModel



@end
