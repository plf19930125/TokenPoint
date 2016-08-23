//
//  ViewController.m
//  TokenPointDemo
//
//  Created by zl on 16/7/6.
//  Copyright © 2016年 zulong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onClickBITest:(id)sender
{
    NSString* randomStr = [self RandomString];
    //NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
    //                       @"appid", @"IosBiTest",
    //                        @"info" , randomStr,
    //                        nil];
    NSString* idfa = [[TokenPoint sharedInstance] GetIDFA];
    NSString* macAddress = [[TokenPoint sharedInstance] GetMacAddress];
    NSString* params = [NSString stringWithFormat:@"%@|%@|%@|%@" , @"207" , idfa , macAddress , randomStr];
    NSLog(@"PARAMS IS :  %@" , params);
    [[TokenPoint sharedInstance] log:params];
}

-(nonnull NSString*) RandomString
{
    char data[20];
    for(int i = 0;i < 20; i++){
        data[i] = (char)('A'+(arc4random_uniform(26)));
    }
    NSString* str = [[NSString alloc] initWithBytes:data length:20 encoding:NSUTF8StringEncoding];
    return str;
}

@end
