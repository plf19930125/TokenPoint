//
//  TokenPointImpl.m
//  TokenPoint
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import "TokenPointImpl.h"

@import AFNetworking;


@implementation TokenPointImpl

AFHTTPSessionManager * httpManager = nil;

-(void) init:(NSString *) baseUrl
{
    NSURL * baseurl = [[NSURL alloc] initWithString:baseUrl];
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
    
}


-(void) log:(nonnull NSDictionary * ) params
    requestid:(nullable NSString * )requestid
    success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error))failure
{
    [httpManager GET:@"" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString * result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",result);
        if(requestid != nil)
            NSLog(@"requestid:%@:",requestid);
        if(success)
            success(task,requestid,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(error != nil)
            NSLog(@"%@",error);
        if(failure)
            failure(task,requestid,error);
    }];

}

-(void) onReachabilityChanged:(AFNetworkReachabilityStatus) status
{
    NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
}

@end
