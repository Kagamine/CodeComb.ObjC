//
//  ProfileController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-20.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "ProfileController.h"
#import "WebAPI.h"

@interface ProfileController ()

@property (weak, nonatomic) IBOutlet UILabel *txtNickname;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *txtRating;
@property (weak, nonatomic) IBOutlet UILabel *txtMotto;

@end

@implementation ProfileController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [WebAPI getProfileWithCompletionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"加载个人信息失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.txtNickname.text = data[@"Nickname"];
        self.txtMotto.text = data[@"Motto"];
        self.txtRating.text = [data[@"Rating"] stringValue];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:data[@"AvatarURL"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            UIImage *avatar = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgAvatar.image = avatar;
            });
        }] resume];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { // Scan code
#pragma mark - todo
        } else if (indexPath.row == 1) { // Logout
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
@end
