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

-(TokenPoint *) init:(nullable NSString *) baseUrl
{
    tpImpl = [TokenPointImpl alloc];
    [tpImpl init:baseUrl];
    return self;
}

-(void) log:(nonnull NSDictionary * ) params
{
    [tpImpl log:params requestid:@"1" success:nil failure:nil];
}


@end