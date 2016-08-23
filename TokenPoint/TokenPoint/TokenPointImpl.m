//
//  TokenPointImpl.m
//  TokenPoint
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

#include <net/if.h>
#include <net/if_dl.h>

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


+(nullable TokenPointImpl*) Instance
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

-(void) saveLogs:(nonnull NSString*)requestId Params:(nullable NSString*)params
{
    if(nil == requestId || nil == params) return;
    
    NSUserDefaults* tokenPointUser = [NSUserDefaults standardUserDefaults];
    NSDictionary* logDic = [tokenPointUser objectForKey:TOKEPOINT_NAME];
    
    NSMutableDictionary* newLogsDic = nil;
    if(nil == logDic)
    {
        newLogsDic = [[NSMutableDictionary alloc] init];
        [newLogsDic setObject:params forKey:requestId];
    }
    else
    {
        newLogsDic = [[NSMutableDictionary alloc] initWithDictionary:logDic];
        [newLogsDic setObject:params forKey:requestId];
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
    //baseUrl = [NSString stringWithFormat:@"%@?gameId=%@&serverId=1&msg=" , baseUrl , appId];
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


-(void) log:(nonnull NSString * ) params
    requestid:(nullable NSString * )requestid
    success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure
{
    NSDictionary* paramsDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [self GetAppId], @"gameId",
                                            @"1" , @"serverId",
                                            params , @"msg",
                                            nil];
    
    [httpManager GET:[self GetBaseUrl] parameters:paramsDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            NSLog(@"Error%@",error);
        if(failure)
            failure(task,requestid,error);
    }];

}


-(void)log:(nonnull NSString *) logMsg
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
    
    [self saveLogs:curRequestId Params:logMsg];
    [self log:logMsg requestid:curRequestId success:success failure:failure];
}

-(void) log:(nonnull NSString*)logMsg
{
    [self log:logMsg success:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject) {
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
            NSString* params = [logDic objectForKey:key];
            [self log:params requestid:key success:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject) {
                NSLog(@"LOG SUCCESS !!!!  requestId is ... %@ ..." , requestid);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error) {
                NSLog(@"LOG FAILED !!!!  requestId is ... %@ ..." , requestid);
            }];
        }
    }
    
}

-(nullable NSString*) GetIDFA
{
    NSString* idfa = @"";
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if(version > 7.0f)
    {
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    else
    {
        idfa = [self GetMacAddress];
    }
    
    if(idfa == nil)
    {
        idfa = @"";
    }
    
    return idfa;

}

-(nullable NSString*) GetMacAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        NSLog(@"Error: if_nametoindex error...");
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        NSLog(@"Error: sysctl error...");
        return nil;
    }
    
    if ((buf = malloc(len)) == NULL) {
        NSLog(@"Could not allocate memory. error!");
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        NSLog(@"Error: sysctl, take 2...");
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    //NSLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}

@end
