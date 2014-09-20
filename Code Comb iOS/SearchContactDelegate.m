//
//  SearchContactDelegate.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-20.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "SearchContactDelegate.h"
#import "WebAPI.h"
#import "ChatController.h"
#import "NavigationController.h"

@interface SearchContactDelegate()

@property (nonatomic,weak) ContactListController *controller;
@property (nonatomic,strong) NSArray *contacts;

@end

@implementation SearchContactDelegate

- (instancetype)initWithController:(ContactListController *)controller
{
    self.controller = controller;
    self.contacts = [NSArray array];
    return self;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [WebAPI findContactsLike:searchString completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"查询失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.contacts = data[@"List"];
        [controller.searchResultsTableView reloadData];
    }];
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contact"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Contact"];
    }
    cell.textLabel.text = self.contacts[indexPath.row][@"Nickname"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *contact = self.contacts[indexPath.row];
    ChatController *controller = [ChatController messagesViewController];
    controller.hisID = [contact[@"UserID"] integerValue];
    controller.hisAvatarURL = [NSURL URLWithString:contact[@"AvatarURL"]];
    controller.hisNickname = contact[@"Nickname"];
    UINavigationController *nav = [[NavigationController alloc] initWithRootViewController:controller];
    [self.controller presentViewController:nav animated:YES completion:nil];
}
@end
