//
//  ChatController.h
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-14.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "JSQMessagesViewController.h"

@interface ChatController : JSQMessagesViewController

@property (nonatomic,copy) NSString *hisNickname;
@property (nonatomic,assign) NSInteger hisID;
@property (nonatomic,copy) NSURL *hisAvatarURL;

@end
