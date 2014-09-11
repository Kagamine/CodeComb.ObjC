//
//  WebAPI.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-11.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "WebAPI.h"
#import <libkern/OSAtomic.h>

@implementation WebAPI

static NSString * const ApiRootURL = @"http://www.codecomb.net/API/";
static NSString *token;
static volatile int32_t pendingCounter;

static void post(NSString *path, NSMutableDictionary *params, WebAPICompletionHandler handler) {
    if (token != nil) {
        [params setObject:token forKey:@"Token"];
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error != nil) {
        NSLog(@"Web API post error:%@",error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:ApiRootURL]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Turn on networking indicator
    if (OSAtomicIncrement32(&pendingCounter) == 1) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (OSAtomicDecrement32(&pendingCounter) == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
        if (error != nil) {
            NSLog(@"Web API post error:%@", error);
            return;
        }
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error != nil) {
            NSLog(@"Web API post error:%@", error);
            return;
        }
        
        NSInteger code = [result[@"Code"] integerValue];
        BOOL success = [result[@"IsSuccess"] boolValue];
        NSString *info = result[@"Info"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(code,success,info,result);
        });
    }] resume];
}

+ (void)getContestsInPage:(NSNumber *)page completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (page != nil) {
        [params setObject:page forKey:@"Page"];
    }
    post(@"GetContests",params,handler);
}

+ (void)authWithUsername:(NSString*)username password:(NSString*)password completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"Username": username, @"Password": password}];
    post(@"Auth", params, ^(NSInteger code, BOOL success, NSString *info, id data) {
        if (success) {
            token = data[@"AccessToken"];
        }
        handler(code,success,info,data);
    });
}

#pragma mark - Helper methods

+ (NSDate *)deserializeJsonDateString: (NSString *)jsonDateString
{
    NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; //get number of seconds to add or subtract according to the client default time zone
    
    NSInteger startPosition = [jsonDateString rangeOfString:@"("].location + 1; //start of the date value
    
    NSTimeInterval unixTime = [[jsonDateString substringWithRange:NSMakeRange(startPosition, 13)] doubleValue] / 1000; //WCF will send 13 digit-long value for the time interval since 1970 (millisecond precision) whereas iOS works with 10 digit-long values (second precision), hence the divide by 1000
    
    NSDate *date = [[NSDate dateWithTimeIntervalSince1970:unixTime] dateByAddingTimeInterval:offset];
    
    return date;
}

@end
