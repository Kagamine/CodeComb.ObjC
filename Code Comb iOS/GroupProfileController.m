//
//  GroupProfileController.m
//  Code Comb iOS
//
//  Created by Gasai Yuno on 14-9-25.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "GroupProfileController.h"
#import "WebAPI.h"

@interface GroupProfileController()

@property (weak, nonatomic) IBOutlet UIImageView *imgGroupAvatar;
@property (weak, nonatomic) IBOutlet UILabel *txtGroupName;
@property (weak, nonatomic) IBOutlet UILabel *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *txtMemberCount;

@end


@implementation GroupProfileController

- (void)getGroupAvatar:(NSURL*)url
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *groupAvatar = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imgGroupAvatar setImage: groupAvatar];
            [self.tableView reloadData];
            [self.imgGroupAvatar.layer setMasksToBounds:YES];
            [self.imgGroupAvatar.layer setCornerRadius:30.0];
        });
    }] resume];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [WebAPI getGroupProfile:self.groupID completitionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
       if(success)
       {
           NSLog(@"Get profile ok.");
           self.txtGroupName.text = data[@"Title"];
           self.txtDescription.text = data[@"Description"];
           self.txtMemberCount.text = [data[@"MemberCount"] stringValue];
           [self getGroupAvatar:[[NSURL alloc] initWithString:data[@"Icon"]]];
           [self.tableView reloadData];
       }
       else
       {
           [[[UIAlertView alloc] initWithTitle:@"加载群资料失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
           return;
       }
    }];
}

@end