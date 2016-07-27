//
//  TokenPointImpl.m
//  TokenPoint
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import "TokenPointImpl.h"

@import AFNetworking;


@interface TokenPointImpl()
{
    NSString* mAppId;
    NSString* mBaseUrl;
    AFHTTPSessionManager* httpManager;
}

@end


@implementation TokenPointImpl

//AFHTTPSessionManager * httpManager = nil;


+(nonnull TokenPointImpl*) Instance
{
    static dispatch_once_t pred = 0;
    __strong static id instance = nil;
    dispatch_once(&pred , ^{
        instance = [[TokenPointImpl alloc] init];
    });
    return (TokenPointImpl*)instance;
}

-(instancetype) init
{
    if(self = [super init])
    {
        mAppId = @"";
        mBaseUrl = @"";
        httpManager = nil;
    }
    return self;
}

-(void) SetAppId:(nullable NSString *)appId
{
    mAppId = appId;
}

-(nullable NSString*) GetAppId
{
    return mAppId;
}

-(void) SetBaseUrl:(nullable NSString *)baseUrl
{
    mBaseUrl = baseUrl;
}

-(nullable NSString*) GetBaseUrl
{
    return mBaseUrl;
}

-(nullable NSString *)GetRequestId
{
    //使用时间轴做id
    NSDate* dateNow = [NSDate date];
    NSString* requestId = [NSString stringWithFormat:@"tokenPoint_%ld" , (long)[dateNow timeIntervalSince1970]];
    return requestId;
}

-(void) saveLogs:(nonnull NSString*)requestId Params:(nullable NSDictionary*)params
{
    if(nil == requestId || nil == params) return;
    
    NSUserDefaults* tokenPointUser = [NSUserDefaults standardUserDefaults];
    NSDictionary* logDic = [tokenPointUser objectForKey:TOKEPOINT_NAME];
    
    NSMutableDictionary* newLogsDic = [[NSMutableDictionary alloc] init];
    if(nil == logDic)
    {
        [newLogsDic setObject:params forKey:requestId];
    }
    else
    {
        newLogsDic = [[NSMutableDictionary alloc] initWithDictionary:logDic];
        [newLogsDic setObject:requestId forKey:params];
    }
    
    [tokenPointUser setObject:newLogsDic forKey:TOKEPOINT_NAME];
    [tokenPointUser synchronize];
}

-(void) deleteLocationLogs:(nonnull NSString*)requestId
{
    if(nil == requestId) return;
    
    NSUserDefaults* tokenPointUser = [NSUserDefaults standardUserDefaults];
    NSDictionary* logDic = [tokenPointUser objectForKey:TOKEPOINT_NAME];
    
    if(nil != logDic && [logDic count] > 0 )
    {
        NSMutableDictionary* newLogsDic = [[NSMutableDictionary alloc] initWithDictionary:logDic];
        [newLogsDic removeObjectForKey:requestId];
        [tokenPointUser setObject:newLogsDic forKey:TOKEPOINT_NAME];
        [tokenPointUser synchronize];
    }
}

-(void) init:(nullable NSString*)appId baseUrl:(nullable NSString *) baseUrl
{
    NSURL * baseurl = [[NSURL alloc] initWithString:baseUrl];
    [self SetAppId:appId];
    [self SetBaseUrl:baseUrl];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseurl  sessionConfiguration:config];
    
    //httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //httpManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET",@"HEAD",@"DELETE",@"POST", nil];;
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",nil];
    
    //reachability
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self onReachabilityChanged:status];
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //上传存储在本地的log
    [self PostLeftLogs];
}


-(void) log:(nonnull NSDictionary * ) params
    requestid:(nullable NSString * )requestid
    success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure
{
    [httpManager GET:[self GetBaseUrl] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString * result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",result);
        if(requestid != nil)
        {
            NSLog(@"requestid:%@:",requestid);
            [self deleteLocationLogs:requestid];
        }
        if(success)
            success(task,requestid,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(error != nil)
            NSLog(@"%@",error);
        if(failure)
            failure(task,requestid,error);
    }];

}


-(void)log:(nonnull NSDictionary *) params
        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid,id  _Nullable responseObject))success
        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure
{
    NSString* curRequestId = [self GetRequestId];
    if(nil == httpManager)
    {
        NSURL * baseurl = [[NSURL alloc] initWithString:[self GetBaseUrl]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseurl  sessionConfiguration:config];
        httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",nil];
    }
    
    [self saveLogs:curRequestId Params:params];
    [self log:params requestid:curRequestId success:success failure:failure];
}

-(void) log:(nonnull NSDictionary*)params
{
    [self log:params success:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject) {
        NSLog(@"LOG SUCCESS !!!!  requestId is ... %@ ..." , requestid);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error) {
        NSLog(@"LOG FAILED !!!!  requestId is ... %@ ..." , requestid);
    }];
}


-(void) onReachabilityChanged:(AFNetworkReachabilityStatus) status
{
    NSLog(@"Network status changed!!!!!   Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
}

-(void) PostLeftLogs
{
    NSUserDefaults* tokenpointUser = [NSUserDefaults standardUserDefaults];
    NSDictionary* logDic = [tokenpointUser objectForKey:TOKEPOINT_NAME];
    if(nil != logDic && [logDic count] > 0)
    {
        NSArray* keys = [logDic allKeys];
        for(NSString* key in keys)
        {
            NSDictionary* params = [logDic objectForKey:key];
            [self log:params requestid:key success:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject) {
                NSLog(@"LOG SUCCESS !!!!  requestId is ... %@ ..." , requestid);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error) {
                NSLog(@"LOG FAILED !!!!  requestId is ... %@ ..." , requestid);
            }];
        }
    }
    
}



@end
