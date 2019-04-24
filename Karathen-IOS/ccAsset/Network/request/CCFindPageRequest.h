//
//  CCFindPageRequest.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/8.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRequest.h"

@class CCFindPageSingle, CCFindPageModel;
@interface CCFindPageRequest : CCRequest

@property (nonatomic, strong) NSArray *dataArray;

- (void)requsetCompletion:(void(^)(void))completion;

@end


@interface CCFindPageModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray <CCFindPageSingle *> *content;

@end


@interface CCFindPageSingle : NSObject

@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pic;

@end
