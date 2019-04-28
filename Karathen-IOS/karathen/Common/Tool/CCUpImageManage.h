//
//  CCUpImageManage.h
//  Karathen
//
//  Created by Karathen on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCUpImageManage : NSObject

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *urls;

- (void)startUploadCompletion:(void(^)(NSArray *urls))completion;

@end


@interface CCQNTokenRequest : CCRequest

- (void)requestCompletion:(void(^)(NSString *token))completion;

@end
