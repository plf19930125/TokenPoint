//
//  TokenPoint.h
//  TokenPoint
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

@interface TokenPoint : NSObject

+(nullable TokenPoint*) sharedInstance;


-(void) init:(nullable NSString*)appId baseUrl:(nullable NSString *) baseUrl;
-(void) log:(nullable NSString * ) logMsg;

-(nullable NSString*) GetIDFA;
-(nullable NSString*) GetMacAddress;

@end

//! Project version number for TokenPoint.
FOUNDATION_EXPORT double TokenPointVersionNumber;

//! Project version string for TokenPoint.
FOUNDATION_EXPORT const unsigned char TokenPointVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TokenPoint/PublicHeader.h>


