//
//  CCRequest.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/20.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRequest.h"


@interface CCRequest ()

///已经使用过缓存
@property (nonatomic, assign) BOOL hadLoadCache;

@end

@implementation CCRequest

#pragma mark - 请求地址
- (NSString *)baseUrl {
    return [CCRequest assetBaseUrl];
}

#pragma mark - init method
- (id)init {
    if (self = [super init]) {
        [self customSet];
    }
    return self;
}


- (id)initWithParameter:(NSDictionary *)parameter {
    if (self = [super init]) {
        _parameter = parameter;
        [self customSet];
    }
    return self;
}

- (id)initWithRequestUrl:(NSString *)url {
    if (self = [super init]) {
        self.urlStr = url;
        [self customSet];
    }
    return self;
}

- (id)initWithParameter:(NSDictionary *)parameter requestUrl:(NSString *)url {
    if (self = [super init]) {
        _parameter = parameter;
        self.urlStr = url;
        [self customSet];
    }
    return self;
}

///默认设置
- (void)customSet {
    _method = YTKRequestMethodPOST;
    _cacheSecond = -1;
}

///请求超时
- (NSTimeInterval)requestTimeoutInterval {
    return 10.f;
}

//缓存时间<使用默认的start，在缓存周期内并没有真正发起请求>
- (NSInteger)cacheTimeInSeconds
{
    return self.cacheSecond;
}


//请求参数
- (id)requestArgument {
    return self.parameter?:@{};
}

- (NSString *)requestUrl {
    return self.urlStr?:@"";
}

- (YTKRequestMethod)requestMethod {
    return self.method;
}


- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}


/////请求头添加参数
//- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    return @{
//             @"version" : version?:@""
//             };
//}

- (void)requestCompletionBlockWithSuccess:(requestSuccess)success failure:(requestFail)failure {
    [self requestCompletionBlockWithSuccess:success failure:failure useCache:NO];
}

- (void)requestCompletionBlockWithSuccess:(requestSuccess)success
                                  failure:(requestFail)failure
                                 useCache:(BOOL)useCache {
    if ([self isExecuting]) {
        [[YTKNetworkAgent sharedAgent] cancelRequest:self];
    }
    if (useCache && [self loadCacheWithError:nil] && !self.hadLoadCache) {
        self.hadLoadCache = YES;
        [self dealRequest:self success:success failure:failure];
    }
    @weakify(self)
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self)
        [self dealRequest:request success:success failure:failure];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *errStr = nil;
        NSError *error = request.error;
        NSInteger code = error.code;
        switch (code) {
            case CCRequestStateFailTimedOut: {
                if (failure) {
                    failure(CCRequestStateFailTimedOut,errStr);
                }
            }
                break;
            case CCRequestStateNotConnectedToInternet: {
                if (failure) {
                    failure(CCRequestStateNotConnectedToInternet,errStr);
                }
            }
                break;
            default: {
                if (failure) {
                    failure(CCRequestStateOtherFail,errStr);
                }
            }
                break;
        }
    }];
}


- (void)dealRequest:(YTKBaseRequest *)request success:(requestSuccess)success failure:(requestFail)failure {
    id responseObject = request.responseJSONObject;
    NSInteger state = [[responseObject objectForKey:@"state"] integerValue];
    NSString *error = [responseObject objectForKey:@"error"];
    switch (state) {
        case CCRequestStateSuccess:
        {
            if (success) {
                success(responseObject);
            }
        }
            break;
        case CCRequestStateFail:
        {
            if (failure) {
                failure(CCRequestStateFail,error);
            }
        }
            break;
    }
}

#pragma mark - 地址
+ (NSString *)assetBaseUrl {
    return CCAppBase_URL;
}

@end
