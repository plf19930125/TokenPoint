//
//  TokenPointImpl.h
//  TokenPoint
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import <Foundation/Foundation.h>

//@import AFNetworking;
#define TOKEPOINT_NAME      @"ZuLong_TokenPoint"

@interface TokenPointImpl : NSObject

+(nullable TokenPointImpl*) Instance;

-(void) init:(nullable NSString*)appId baseUrl:(nullable NSString *) baseUrl;
-(void) SetAppId:(nullable NSString*)appId;
-(nullable NSString*) GetAppId;
-(void) SetBaseUrl:(nullable NSString*)baseUrl;
-(nullable NSString*) GetBaseUrl;

-(nullable NSString*) GetIDFA;
-(nullable NSString*) GetMacAddress;

-(nullable NSString*) GetRequestId;

-(void) log:(nonnull NSString * ) logMsg
  requestid:(nullable NSString * )requestid
    success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid,id  _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure;

-(void) log:(nonnull NSString *) logMsg  success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid,id  _Nullable responseObject))success  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure;

-(void) log:(nonnull NSString*) logMsg;

@end
