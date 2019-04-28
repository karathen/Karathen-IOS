//
//  CCUpImageManage.m
//  Karathen
//
//  Created by Karathen on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCUpImageManage.h"
#import <Qiniu/QNUploadManager.h>

@interface CCUpImageManage ()

@property (nonatomic, strong) CCQNTokenRequest *tokenRequest;
@property (nonatomic, strong) NSString *token;

@end


@implementation CCUpImageManage

- (void)startUploadCompletion:(void (^)(NSArray *))completion {
    @weakify(self)
    [self.tokenRequest requestCompletion:^(NSString *token) {
        @strongify(self)
        if (token) {
            self.token = token;
            [self.urls removeAllObjects];
            [self upImagesWithToken:token completion:completion];
        } else {
            completion(nil);
        }
    }];
}

- (void)upImagesWithToken:(NSString *)token completion:(void (^)(NSArray *))completion {
    @weakify(self)
    [self upImagesIndex:0 finishBlock:^{
        @strongify(self)
        completion(self.urls);
    }];
}

- (void)upImagesIndex:(NSInteger)index finishBlock:(void(^)(void))finishBlock {
    if (self.images.count > index) {
        @weakify(self)
        [self uploadImage:self.images[index] completion:^(NSString *url) {
            @strongify(self)
            if (url) {
                [self.urls addObject:url];
            }
            [self upImagesIndex:index+1 finishBlock:finishBlock];
        }];
    } else {
        finishBlock();
    }
}

- (void)uploadImage:(UIImage *)image completion:(void(^)(NSString *url))completion {
    QNUploadManager *manager = [[QNUploadManager alloc] init];
    NSData *imageData = UIImagePNGRepresentation(image);
    [manager putData:imageData key:nil token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (resp && resp[@"key"]) {
            if (completion) {
                completion([NSString stringWithFormat:@"%@%@",CC_QINIU_IMAGE,resp[@"key"]]);
            }
        } else {
            completion(nil);
        }
    } option:nil];
}

#pragma mark - get
- (CCQNTokenRequest *)tokenRequest {
    if (!_tokenRequest) {
        _tokenRequest = [[CCQNTokenRequest alloc] init];
    }
    return _tokenRequest;
}

- (NSMutableArray *)urls {
    if (!_urls) {
        _urls = [NSMutableArray array];
    }
    return _urls;
}

@end


@implementation CCQNTokenRequest

- (NSString *)requestUrl {
    return @"";
}

- (NSDictionary *)requestArgument {
    return @{
             @"id":@"1",
             @"method":@"qiniuToken",
             @"jsonrpc":@"2.0",
             @"params":@[]
             };
}

- (void)requestCompletion:(void(^)(NSString *token))completion {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseBody = request.responseObject;
        NSString *result = responseBody[@"result"];
        if (result) {
            completion(result);
        } else {
            completion(nil);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(nil);
    }];
}

@end
