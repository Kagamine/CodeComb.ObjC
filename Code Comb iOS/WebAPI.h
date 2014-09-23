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

+ (void)getContestsInPage:(NSInteger)page completionHandler:(WebAPICompletionHandler)handler;
+ (void)authWithUsername:(NSString*)username password:(NSString*)password completionHandler:(WebAPICompletionHandler)handler;
+ (void)getClarificationsOfContest:(NSInteger)contestID completionHandler:(WebAPICompletionHandler)handler;
+ (void)responseClarification:(NSInteger)clarificationID answer:(NSString*)answer status:(NSInteger)status completionHandler:(WebAPICompletionHandler)handler;
+ (void)registerPushServiceWithDeviceToken:(NSString*)deviceToken completionHandler:(WebAPICompletionHandler)handler;
+ (void)getContactsWithCompletionHandler:(WebAPICompletionHandler)handler;
+ (void)broadcast:(NSString*)message completionHandler:(WebAPICompletionHandler)handler;
+ (void)getProfileWithCompletionHandler:(WebAPICompletionHandler)handler;
+ (void)getChatRecordsWith:(NSInteger)userID completionHandler:(WebAPICompletionHandler)handler;
+ (void)sendMessageTo:(NSInteger)userID content:(NSString*)content completionHandler:(WebAPICompletionHandler)handler;
+ (void)findContactsLike:(NSString*)nickname completionHandler:(WebAPICompletionHandler)handler;
+ (void)loginByQRCode:(NSString *)qrcode completitionHandler:(WebAPICompletionHandler)handler;
+ (NSDate *)deserializeJsonDateString: (NSString *)jsonDateString;
+ (void) createGroup:(NSString *)title description:(NSString *)description joinMethod:(NSInteger)joinMethod  completionHandler:(WebAPICompletionHandler)handler;
+ (void) modifyGroup: (NSInteger)groupID title:(NSString *)title description:(NSString *)description joinMethod:(NSInteger)joinMethod  completionHandler:(WebAPICompletionHandler)handler;
+ (void) kickGroupMember: (NSInteger)groupID userID:(NSInteger)userID completitionHandler:(WebAPICompletionHandler)handler;
+ (void) joinGroup: (NSInteger)groupID message:(NSString *)message completitionHandler:(WebAPICompletionHandler)handler;
+ (void) getGroupApplications: (NSInteger)groupID page:(NSInteger)page completitionHandler:(WebAPICompletionHandler)handler;
+ (void) responseGroupApplication: (NSInteger) applicationID status:(NSInteger)status response:(NSString *)response completitionHandler:(WebAPICompletionHandler)handler;
+ (void) getGroupChat: (NSInteger) groupID page:(NSInteger) page completitionHandler:(WebAPICompletionHandler)handler;
+ (void) sendGroupMessage: (NSInteger)groupID message: (NSString *)message completitionHandler:(WebAPICompletionHandler)handler;
+ (void) quitGroup: (NSInteger)groupID completitionHandler:(WebAPICompletionHandler)handler;
+ (void) getGroups: (NSInteger)page completitionHandler:(WebAPICompletionHandler)handler;
+ (void) getGroupHomeworks: (NSInteger)groupID page:(NSInteger)page completitionHandler:(WebAPICompletionHandler)handler;
+ (void) getGroupHomeworkStandings: (NSInteger)groupHomeworkID completitionHandler:(WebAPICompletionHandler)handler;

@end
