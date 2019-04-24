//
//  CCCoreData.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData.h"


static CCCoreData *coreData = nil;

@interface CCCoreData ()


@end

@implementation CCCoreData

+ (CCCoreData *)coreData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreData = [[CCCoreData alloc] init];
    });
    return coreData;
}

#pragma mark - 保存
- (void)saveDataCompletion:(saveCompletion)completion {
    NSError *error = nil;
    BOOL suc = [self.managedObjectContext save:&error];
    if (completion) {
        completion(suc, error);
    }
}

#pragma mark - get
- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        //获取模型路径
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CCWallet" withExtension:@"momd"];
        //根据模型文件创建模型对象
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        //利用模型对象创建助理对象
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        //数据库的名称和路径
        NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sqlPath = [docStr stringByAppendingPathComponent:CC_COREDATA_SQLITE];
        NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
        NSError *error = nil;
        //设置数据库相关信息 添加一个持久化存储库并设置存储类型和路径，NSSQLiteStoreType：SQLite作为存储库
        NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                           NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
                                           NSInferMappingModelAutomaticallyOption, nil];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:optionsDictionary error:&error];
        
        if (error) {
            DLog(@"添加数据库失败:%@",error);
        } else {
            DLog(@"添加数据库成功");
        }
    }
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        //创建上下文 保存信息 操作数据库
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}



@end
