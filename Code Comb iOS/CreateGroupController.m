//
//  CreateGroupController.m
//  Code Comb iOS
//
//  Created by Gasai Yuno on 14-9-23.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "CreateGroupController.h"
#import "WebAPI.h"

NSInteger joinMethod = -1;
NSIndexPath *checkedIndexPath;

@interface CreateGroupController()
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;

@end

@implementation CreateGroupController

- (void) viewdidload
{
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1)
    {
        if (checkedIndexPath)
        {
            if ([checkedIndexPath isEqual:indexPath]) return;
            UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:checkedIndexPath];
            [uncheckCell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        checkedIndexPath = indexPath;
        joinMethod = indexPath.row;
    }
    else if(indexPath.section == 2)
    {
        if(self.txtTitle.text == nil || self.txtTitle.text.length == 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入一个群名称" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        if(joinMethod == -1)
        {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请设置一个入群方式" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        [WebAPI createGroup:self.txtTitle.text description:self.txtDescription.text joinMethod:(joinMethod) completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
            if(success)
            {
                //todo: pop view
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"创建失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            }
        }];
    }
}

@end