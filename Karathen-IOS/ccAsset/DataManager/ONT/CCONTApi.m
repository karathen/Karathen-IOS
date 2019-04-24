//
//  CCONTApi.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCONTApi.h"
#import "ONTAccount.h"

static CCONTApi *manager = nil;

@interface CCONTApi ()

@property (nonatomic, strong) CCONTRequest *request;
@property (nonatomic, strong) CCONTRpcRequest *rpcRequest;
@property (nonatomic, strong) CCONTExplorer *exploerRequest;

@end

@implementation CCONTApi

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCONTApi alloc] init];
    });
    return manager;
}

#pragma mark - 查询价格
- (void)getBalanceWithAddress:(NSString *)address
                   completion:(void(^)(NSDictionary *balance))completion {
    self.rpcRequest.parameter = @{
                               @"id":@"1",
                               @"method":@"getbalance",
                               @"jsonrpc":@"2.0",
                               @"params":@[address]
                               };
    [self.rpcRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = request.responseObject[@"result"];
        completion(result);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(nil);
    }];
}

#pragma mark - 转账
- (void)transferAccount:(ONTAccount *)account
                  asset:(CCAsset *)asset
            fromAddress:(NSString *)fromAddress
              toAddress:(NSString *)toAddress
                 number:(NSString *)number
             completion:(void(^)(BOOL suc,NSString *txId))completion {
    NSString *txHex = [account makeTransferToAddress:toAddress tokenAddress:asset.tokenAddress amount:number decimal:asset.tokenDecimal gasPrice:500 gasLimit:20000];
    self.rpcRequest.parameter = @{
                               @"id":@"1",
                               @"method":@"sendrawtransaction",
                               @"jsonrpc":@"2.0",
                               @"params":@[txHex,@(0)]
                               };
    [self.rpcRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *resp = request.responseObject;
        NSInteger error = [resp[@"error"] integerValue];
        if (error == 0) {
            completion(YES,resp[@"result"]);
        } else {
            completion(NO,nil);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,nil);
    }];
}

#pragma mark - 交易记录
- (void)getTransationWithAddress:(NSString *)address
                    tokenAddress:(NSString *)tokenAddress
                            page:(NSInteger)page
                      completion:(void(^)(BOOL suc,NSArray *records))completion {
    if ([tokenAddress containsString:ONT_CONTRACT]) {
        tokenAddress = @"0100000000000000000000000000000000000000";
    } else if ([tokenAddress containsString:ONG_CONTRACT]) {
        tokenAddress = @"0200000000000000000000000000000000000000";
    }
    self.request.parameter = @{
                               @"id":@"1",
                               @"method":@"getTransactionByAddress",
                               @"jsonrpc":@"2.0",
                               @"params":@[address,tokenAddress,@(page)]
                               };
    [self.request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseObject = request.responseObject;
        if (responseObject[@"error"] || !responseObject[@"result"]) {
            completion(NO,nil);
        } else {
            completion(YES,responseObject[@"result"]);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,nil);
    }];
    
}


#pragma mark - 获取ONG
- (void)getONGWithAddress:(NSString *)address
               completion:(void(^)(BOOL suc,NSString *claimedONG,NSString *unClaimedONG))completion {
    self.exploerRequest.urlStr = [NSString stringWithFormat:@"address/%@/0/0",address];
    self.exploerRequest.method = YTKRequestMethodGET;
    [self.exploerRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *resultData = [request.responseObject valueForKey:@"Result"];
        NSArray *array = resultData[@"AssetBalance"];
        if (array) {
            NSString *waitboundong = @"0";
            NSString *unboundong = @"0";
            for (NSDictionary *dic in array) {
                NSString *AssetName = dic[@"AssetName"];
                NSString *Balance = dic[@"Balance"];
                if ([AssetName compareWithString:@"waitboundong"]) {
                    waitboundong = Balance;
                }
                if ([AssetName compareWithString:@"unboundong"]) {
                    unboundong = Balance;
                }
            }
            completion(YES,unboundong,waitboundong);
        } else {
            completion(NO,@"0",@"0");
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,@"0",@"0");
    }];
}

#pragma mark - 提取ONG
- (void)claimWalletData:(CCWalletData *)walletData
               password:(NSString *)password
                 amount:(NSString *)ammount
             completion:(void (^)(BOOL suc, CCWalletError error))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:walletData.wallet.accountID password:password completion:^(NSString *walletInfo) {
        @strongify(self)
        [self claimWalletData:walletData walletInfo:walletInfo amount:ammount completion:completion];
    }];

}

- (void)claimWalletData:(CCWalletData *)walletData
             walletInfo:(NSString *)walletInfo
                 amount:(NSString *)ammount
             completion:(void (^)(BOOL suc, CCWalletError error))completion {
    if (!walletInfo) {
        if (completion) {
            completion(NO,CCWalletErrorPWD);
        }
        return;
    }
    ONTAccount *account;
    switch (walletData.importType) {
        case CCImportTypeSeed:
        case CCImportTypeMnemonic:
            account = [[ONTAccount alloc] initWithMnemonic:walletInfo slot:walletData.wallet.slot];
            break;
        case CCImportTypePrivateKey:
            account = [[ONTAccount alloc] initWithPrivateKey:walletInfo];
            break;
        case CCImportTypeWIF:
            account = [[ONTAccount alloc] initWithWIF:walletInfo];
            break;
        default:
            break;
    }
    
    NSString *txHex = [account makeClaimOngTxWithAddress:walletData.address amount:ammount gasPrice:500 gasLimit:20000];
    self.rpcRequest.parameter = @{
                                  @"id":@"1",
                                  @"method":@"sendrawtransaction",
                                  @"jsonrpc":@"2.0",
                                  @"params":@[txHex,@(0)]
                                  };
    [self.rpcRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *resp = request.responseObject;
        NSInteger error = [resp[@"error"] integerValue];
        if (error == 0) {
            completion(YES,CCWalletClaimGasSuccess);
        } else {
            completion(NO,CCWalletClaimGasSuccess);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,CCWalletClaimGasFail);
    }];
}

#pragma mark - 获取交易信息
- (void)getONTTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion {
    CCONTRpcRequest *request = [[CCONTRpcRequest alloc] init];
    request.parameter = @{
                                  @"id":@"1",
                                  @"method":@"getrawtransaction",
                                  @"jsonrpc":@"2.0",
                                  @"params":@[txId,@(1)]
                                  };
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *resultData = [request.responseObject valueForKey:@"result"];
        completion(resultData);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(nil);
    }];
}

#pragma mark - 获取交易状态
- (void)getONTTransactionStatusWithTxIds:(NSArray *)txIds
                              completion:(void(^)(NSDictionary *statusDic))completion {
    NSMutableArray *requestArray = [NSMutableArray array];
    for (NSString *txId in txIds) {
        CCONTRpcRequest *requset = [[CCONTRpcRequest alloc] init];
        requset.parameter = @{
                              @"id":@"1",
                              @"method":@"getsmartcodeevent",
                              @"jsonrpc":@"2.0",
                              @"params":@[[txId hasPrefix:@"0x"]?[txId substringFromIndex:2]:txId]
                              };
        [requestArray addObject:requset];
    }
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArray];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        NSMutableDictionary *statusDic = [NSMutableDictionary dictionary];
        for (YTKRequest *request in batchRequest.requestArray) {
            NSArray *array = request.requestArgument[@"params"];
            NSDictionary *result = request.responseObject[@"result"];
            if (result && [result isKindOfClass:[NSDictionary class]]) {
                id state = result[@"State"];
                if ([state respondsToSelector:@selector(boolValue)]) {
                    NSString *txId = array.lastObject;
                    [statusDic setValue:@([state boolValue]) forKey:txId];
                }
            }
        }
        if (completion) {
            completion(statusDic);
        }
    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - get
- (CCONTRequest *)request {
    if (!_request) {
        _request = [[CCONTRequest alloc] init];
    }
    return _request;
}

- (CCONTRpcRequest *)rpcRequest {
    if (!_rpcRequest) {
        _rpcRequest = [[CCONTRpcRequest alloc] init];
    }
    return _rpcRequest;
}

- (CCONTExplorer *)exploerRequest {
    if (!_exploerRequest) {
        _exploerRequest = [[CCONTExplorer alloc] init];
    }
    return _exploerRequest;
}

@end

@implementation CCONTRequest

- (NSString *)baseUrl {
    return CC_ONT_BASEURL;
}

- (NSString *)requestUrl {
    return @"";
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}


@end


//https://github.com/ontio/ontology/blob/master/docs/specifications/rpc_api_CN.md#7-sendrawtransaction
@implementation CCONTRpcRequest

- (NSString *)baseUrl {
    return CC_ONT_NODE;
}

- (NSString *)requestUrl {
    return @"";
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

@end


//
@implementation CCONTExplorer

- (NSString *)baseUrl {
    return CC_ONT_EXPLORER;
}


- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

@end

