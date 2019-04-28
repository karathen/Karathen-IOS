//
//  CCRequest.h
//  Karathen
//
//  Created by Karathen on 2018/7/20.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

typedef NS_ENUM(NSInteger, CCRequestState) {
    CCRequestStateSuccess                  = 1,//成功
    CCRequestStateFail                     = 0,//失败
    
    CCRequestStateFailTimedOut             = -1001,//超时
    CCRequestStateNotConnectedToInternet   = -1009,//无法连接到网络
    
    CCRequestStateOtherFail,//还没有定义失败原因
    CCRequestStateNone,//还没有定义的状态码
};


typedef void(^requestSuccess)(id responseBody);
typedef void(^requestFail)(CCRequestState requestType,NSString *errorMsg);

@interface CCRequest : YTKRequest

///请求链接
@property (nonatomic, strong) NSString *urlStr;
///post or other
@property (nonatomic, assign) YTKRequestMethod method;
///缓存时间
@property (nonatomic, assign) NSInteger cacheSecond;
//参数
@property (nonatomic, strong) NSDictionary *parameter;


///method
- (id)initWithParameter:(NSDictionary *)parameter;
- (id)initWithRequestUrl:(NSString *)url;
- (id)initWithParameter:(NSDictionary *)parameter requestUrl:(NSString *)url;


/**
 请求

 @param success 成功
 @param failure 失败
 */
- (void)requestCompletionBlockWithSuccess:(requestSuccess)success
                                  failure:(requestFail)failure;


/**
 请求

 @param success 成功
 @param failure 失败
 @param useCache 是否使用缓存 YES 使用缓存
 */
- (void)requestCompletionBlockWithSuccess:(requestSuccess)success
                                  failure:(requestFail)failure
                                 useCache:(BOOL)useCache;

+ (NSString *)assetBaseUrl;

@end
