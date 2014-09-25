//
//  GroupChatController.h
//  Code Comb iOS
//
//  Created by Gasai Yuno on 14-9-24.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "JSQMessagesViewController.h"

@interface GroupChatController : JSQMessagesViewController

//@property (nonatomic,copy) NSString *hisNickname;
//@property (nonatomic,assign) NSInteger hisID;
//@property (nonatomic,copy) NSURL *hisAvatarURL;
@property (nonatomic,assign) NSInteger groupID;
@property (nonatomic,assign) NSString *groupName;

@end