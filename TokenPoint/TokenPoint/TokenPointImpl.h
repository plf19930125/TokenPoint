//
//  TokenPointImpl.h
//  TokenPoint
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokenPointImpl : NSObject

-(void) init:(nullable NSString *) baseUrl;
-(void) log:(nonnull NSDictionary * ) params
  requestid:(nullable NSString * )requestid
    success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid,id  _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure;

@end
