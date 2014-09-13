//
//  WebAPI.h
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-11.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebAPI : NSObject

typedef void (^WebAPICompletionHandler)(NSInteger code,BOOL success,NSString *info,id data);

+ (void)getContestsInPage:(NSNumber *)page completionHandler:(WebAPICompletionHandler)handler;
+ (void)authWithUsername:(NSString*)username password:(NSString*)password completionHandler:(WebAPICompletionHandler)handler;
+ (void)getClarificationsOfContest:(NSInteger)contestID completionHandler:(WebAPICompletionHandler)handler;
+ (void)responseClarification:(NSInteger)clarificationID answer:(NSString*)answer status:(NSInteger)status completionHandler:(WebAPICompletionHandler)handler;
+ (void)registerPushServiceWithDeviceToken:(NSString*)deviceToken completionHandler:(WebAPICompletionHandler)handler;
+ (void)getContactsWithCompletionHandler:(WebAPICompletionHandler)handler;

+ (NSDate *)deserializeJsonDateString: (NSString *)jsonDateString;

@end
