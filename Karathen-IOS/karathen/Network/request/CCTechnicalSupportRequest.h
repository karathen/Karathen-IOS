//
//  CCTechnicalSupportRequest.h
//  Karathen
//
//  Created by Karathen on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCTechnicalSupportRequest : CCRequest

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSArray *urls;

- (void)supportRequet:(void(^)(BOOL suc,NSString *msg))completion;

@end

NS_ASSUME_NONNULL_END
