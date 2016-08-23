//
//  TokenPoint.m
//  TokenPoint
//
//  Created by zl on 16/7/7.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "TokenPoint.h"
#import "TokenPointImpl.h"

@interface TokenPoint()
{
    TokenPointImpl * tpImpl;
}
@end

@implementation TokenPoint

+(nullable TokenPoint*) sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id instance = nil;
    dispatch_once(&pred , ^{
        instance = [[TokenPoint alloc] init];
    });
    return (TokenPoint*)instance;
}

-(instancetype) init
{
    if(self = [super init])
    {
        tpImpl = [TokenPointImpl Instance];
    }
    return self;
}

-(void) init:(nullable NSString*)appId  baseUrl:(nullable NSString *) baseUrl
{
    //tpImpl = [TokenPointImpl alloc];
    //[tpImpl init:appId baseUrl:baseUrl];
    if(nil == tpImpl)
    {
        tpImpl = [TokenPointImpl Instance];
    }
    [tpImpl init:appId baseUrl:baseUrl];
    
}

-(void) log:(nullable NSString * ) logMsg
{
    if(nil == tpImpl || nil == logMsg)
        return;
    
    //[tpImpl log:params requestid:@"1" success:nil failure:nil];
    //[tpImpl log:params success:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, id  _Nullable responseObject) {
    //    NSLog(@"LOG SUCCESS !!!!  requestId is ... %@ ..." , requestid);
    //} failure:^(NSURLSessionDataTask * _Nullable task, NSString * _Nullable requestid, NSError * _Nullable error) {
    //    NSLog(@"LOG FAILED !!!!  requestId is ... %@ ..." , requestid);
    //}];
    [tpImpl log:logMsg];
}

-(nullable NSString*) GetIDFA
{
    if(tpImpl != nil)
        return [tpImpl GetIDFA];
    
    return nil;
}

-(nullable NSString*) GetMacAddress
{
    if( tpImpl != nil)
        return [tpImpl GetMacAddress];
    
    return nil;
}

@end