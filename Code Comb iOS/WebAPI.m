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
        NSLog(@"Web API post encode error:%@",error);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:ApiRootURL]];
    NSLog(@"WebAPI request to %@: %@",url,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
            NSLog(@"Web API post response error:%@", error);
            return;
        }
        
        NSLog(@"Server response: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error != nil) {
            NSLog(@"Web API post decode error:%@", error);
            return;
        }
        
        NSInteger code = [result[@"Code"] integerValue];
        BOOL success = [result[@"IsSuccess"] boolValue];
        NSString *info = result[@"Info"];
        
        if (handler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(code,success,info,result);
            });
        }
    }] resume];
}

+ (void)getContestsInPage:(NSInteger)page completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"Page": @(page)}];
    post(@"GetContests",params,handler);
}

+ (void)authWithUsername:(NSString*)username password:(NSString*)password completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"Username": username, @"Password": password}];
    post(@"Auth", params, ^(NSInteger code, BOOL success, NSString *info, id data) {
        if (success) {
            token = data[@"AccessToken"];
        }
        
        if (handler != nil) {
            handler(code,success,info,data);
        }
    });
}

+ (void)getClarificationsOfContest:(NSInteger)contestID completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"ContestID": @(contestID)}];
    post(@"GetClarifications", params, handler);
}

+ (void)responseClarification:(NSInteger)clarificationID answer:(NSString *)answer status:(NSInteger)status completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"ClarID": @(clarificationID),@"Status":@(status),@"Answer":answer}];
    post(@"ResponseClarification", params, handler);
}

+ (void)registerPushServiceWithDeviceToken:(NSString *)deviceToken completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"DeviceToken": deviceToken,@"DeviceType":@1}];
    post(@"RegisterPushService", params, handler);
}

+ (void)getContactsWithCompletionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    post(@"GetContacts", params, handler);
}

+ (void)broadcast:(NSString *)message completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"Message": message}];
    post(@"BroadCast", params, handler);
}

+ (void)getProfileWithCompletionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    post(@"GetProfile", params, handler);
}

+ (void)getChatRecordsWith:(NSInteger)userID completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"UserID": @(userID)}];
    post(@"GetChatRecords", params, handler);
}

+ (void)sendMessageTo:(NSInteger)userID content:(NSString *)content completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"UserID": @(userID),@"Content":content}];
    post(@"SendMessage", params, handler);
}

+ (void)findContactsLike:(NSString *)nickname completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"Nickname": nickname}];
    post(@"FindContacts", params, handler);
}

+ (void)loginByQRCode:(NSString *)qrcode completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"BarCode": qrcode}];
    post(@"LoginByBarCode", params, handler);
}

+ (void) createGroup:(NSString *)title description:(NSString *)description joinMethod:(NSInteger)joinMethod  completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"Title": title, @"Description": description, @"JoinMethod": @(joinMethod)}];
    post(@"CreateGroup", params, handler);
}

+ (void) modifyGroup: (NSInteger)groupID title:(NSString *)title description:(NSString *)description joinMethod:(NSInteger)joinMethod  completionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID), @"Title": title, @"Description": description, @"JoinMethod": @(joinMethod)}];
    post(@"ModifyGroup", params, handler);
}

+ (void) kickGroupMember: (NSInteger)groupID userID:(NSInteger)userID completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID), @"UserID": @(userID)}];
    post(@"KickGroupMember", params, handler);
}

+ (void) joinGroup: (NSInteger)groupID message:(NSString *)message completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID), @"Message": message}];
    post(@"JoinGroup", params, handler);
}

+ (void) getGroupApplications: (NSInteger)groupID page:(NSInteger)page completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID), @"Page": @(page)}];
    post(@"GetGroupApplications", params, handler);
}

+ (void) responseGroupApplication: (NSInteger) applicationID status:(NSInteger)status response:(NSString *)response completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"ApplicationID": @(applicationID), @"Response": response}];
    post(@"ResponseGroupApplication", params, handler);
}

+ (void) getGroupChat: (NSInteger) groupID page:(NSInteger) page completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID), @"Page": @(page)}];
    post(@"GetGroupChat", params, handler);
}

+ (void) sendGroupMessage: (NSInteger)groupID message: (NSString *)message completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID), @"message": message}];
    post(@"SendGroupMessage", params, handler);
}

+ (void) quitGroup: (NSInteger)groupID completitionHandler:(WebAPICompletionHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"GroupID": @(groupID)}];
    post(@"QuitGroup", params, handler);
}

#pragma mark - Helper methods

+ (NSDate *)deserializeJsonDateString: (NSString *)jsonDateString
{
    NSInteger startPosition = [jsonDateString rangeOfString:@"("].location + 1; //start of the date value
    
    NSTimeInterval unixTime = [[jsonDateString substringWithRange:NSMakeRange(startPosition, 13)] doubleValue] / 1000; //WCF will send 13 digit-long value for the time interval since 1970 (millisecond precision) whereas iOS works with 10 digit-long values (second precision), hence the divide by 1000
    
    return [NSDate dateWithTimeIntervalSince1970:unixTime];
}

@end
