//
//  WebAPI.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-11.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "WebAPI.h"

@implementation WebAPI

static NSString * const ApiRootURL = @"http://www.codecomb.net/API/";
static NSString *token;

static id post(NSString *path, NSMutableDictionary *params) {
    [params setObject:token forKey:@"Token"];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error != nil) {
        NSLog(@"Web api post error:%@",error);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:ApiRootURL]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }] resume];
    
    //TODO Continue Coding
    return nil;
}

+ (void)GetContestsInPage:(NSNumber *)page completionHandler:(void(^)(BOOL success, NSString *info, NSArray *contests))handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (page != nil) {
        [params setObject:page forKey:@"Page"];
    }
    post(@"GetContests",params);
}

@end
