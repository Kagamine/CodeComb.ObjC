//
//  WebAPI.h
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-11.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebAPI : NSObject

+ (void)GetContestsInPage:(NSNumber *)page completionHandler:(void(^)(BOOL success, NSString *info, NSArray *contests))handler;

@end
