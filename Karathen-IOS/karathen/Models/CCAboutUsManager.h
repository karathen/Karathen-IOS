//
//  CCAboutUsManager.h
//  Karathen
//
//  Created by Karathen on 2018/9/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CCAboutUsType) {
    CCAboutUsTypeService,//服务协议
    CCAboutUsTypePrivacy,//隐私政策
    CCAboutUsTypeUpdate,//检查更新
    CCAboutUsTypeContact,//联系我们
};


@interface CCAboutUsManager : NSObject

+ (NSArray *)dataArray;

@end


@interface CCAboutUsModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) CCAboutUsType type;

@end
