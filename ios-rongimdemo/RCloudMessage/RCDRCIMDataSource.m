//
//  RCDRCIMDelegateImplementation.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "AFHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDLoginInfo.h"
#import "RCDGroupInfo.h"
#import "RCDUserInfo.h"
#import "RCDHttpTool.h"
#import "DBHelper.h"

@interface RCDRCIMDataSource ()

@end

@implementation RCDRCIMDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置信息提供者
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        [[RCIM sharedRCIM] setGroupInfoDataSource:self];
        
        //同步群组
        [self syncGroups];
        [self CreateUserTable];
    }
    return self;
}

+ (RCDRCIMDataSource*)shareInstance
{
    static RCDRCIMDataSource* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];

    });
    return instance;
}

-(void) startServiceWithAppKey:(NSString *) appKey
                     userToken:(NSString *) userToken
{
    //初始化RongCloud SDK
    [[RCIM sharedRCIM] initWithAppKey:appKey deviceToken:nil];
    
    //登陆RongCloud Server
    [[RCIM sharedRCIM] connectWithToken:userToken
    
       success:^(NSString *userId) {
           NSAssert(userId, @"connect success!");
      } error:^(RCConnectErrorCode status) {
        
    }
     tokenIncorrect:^{
         
     }];
}


-(void) syncGroups
{
    //开发者调用自己的服务器接口获取所属群组信息，同步给融云服务器，也可以直接
    //客户端创建，然后同步
    [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
        if ([result count]) {
            //同步群组
            [[RCIMClient sharedRCIMClient] syncGroups:result
                                         success:^{
                //DebugLog(@"同步成功!");
            } error:^(RCErrorCode status) {
                //DebugLog(@"同步失败!  %ld",(long)status);
                
            }];
        }
    }];

}

#pragma mark - GroupInfoFetcherDelegate
- (void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup*))completion
{
    if ([groupId length] == 0)
        return;
    
    //开发者调自己的服务器接口根据userID异步请求数据
    [RCDHTTPTOOL getGroupByID:groupId
            successCompletion:^(RCGroup *group)
    {
                completion(group);
    }];
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    if ([userId length] == 0)
        return;
    RCUserInfo *userInfo=[self getUserByUserId:userId];
    if (userInfo==nil) {
        //开发者调自己的服务器接口根据groupID异步请求数据
        [RCDHTTPTOOL getUserInfoByUserID:userId
                              completion:^(RCUserInfo *user) {
                                  if (user) {
                                      [self insertUserToDB:user];
                                      completion(user);
                                  }
                              }];
    }else
    {
        completion(userInfo);
    }
    
}
static NSString * const userTableName = @"USERTABLE";

//创建用户存储表
-(void)CreateUserTable
{
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        if (![DBHelper isTableOK: userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE INDEX idx_userid ON USERTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
    }];
    
}

//存储用户信息
-(void)insertUserToDB:(RCUserInfo*)user
{
    NSString *insertSql = @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,user.userId,user.name,user.portraitUri];
    }];
    
}
//从表中获取用户信息
-(RCUserInfo*) getUserByUserId:(NSString*)userId
{
    __block RCUserInfo *model = nil;
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?",userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}



@end
