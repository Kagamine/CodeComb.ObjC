//
//  ContactListController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-13.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "ContactListController.h"
#import "WebAPI.h"
#import "ChatController.h"
#import "SearchContactDelegate.h"
#import "QuartzCore/QuartzCore.h"

@interface ContactListController ()

@property (strong) NSArray *contacts;
@property (strong) NSMutableArray *images;
@property (nonatomic,strong) SearchContactDelegate *searchDelegate;

@end

@implementation ContactListController

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
    
    self.contacts = [NSArray array];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.searchDelegate = [[SearchContactDelegate alloc] initWithController:self];
    self.searchDisplayController.delegate = self.searchDelegate;
    self.searchDisplayController.searchResultsDataSource = self.searchDelegate;
    self.searchDisplayController.searchResultsDelegate = self.searchDelegate;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [WebAPI getContactsWithCompletionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"加载失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
             return;
        }
        
        self.contacts = data[@"List"];
        self.images = [NSMutableArray arrayWithCapacity:self.contacts.count];
        for (NSInteger i = 0; i < self.contacts.count; i++) {
            [self.images addObject:[NSNull null]];
            [self startDownloadImageFrom:[NSURL URLWithString:self.contacts[i][@"AvatarURL"]] forIndex:i];
        }
        [self.tableView reloadData];
    }];
}

- (void)startDownloadImageFrom:(NSURL*)url forIndex:(NSInteger)index
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.images setObject:[UIImage imageWithData:data] atIndexedSubscript:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];;
        });
    }] resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contact" forIndexPath:indexPath];
    
    NSDictionary *contact = self.contacts[indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = contact[@"Nickname"];
    UILabel *mottoLabel = (UILabel *)[cell viewWithTag:102];
    mottoLabel.text = contact[@"Motto"];
    UILabel *unreadLabel = (UILabel *)[cell viewWithTag:103];
    //cell.textLabel.text = contact[@"Nickname"];
    if ([contact[@"UnreadMessageCount"] integerValue] > 0) {
        unreadLabel.text = [contact[@"UnreadMessageCount"] stringValue];
    } else {
        unreadLabel.text = @"";
    }
    UIImageView *avatar = (UIImageView*)[cell viewWithTag:100];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 8.0;
    
    if (self.images[indexPath.row] == [NSNull null]) {
        avatar.image = nil;
    } else {
        avatar.image = self.images[indexPath.row];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Chat"]) {
        UINavigationController *nav = segue.destinationViewController;
        ChatController *controller = (ChatController *)[nav topViewController];
        NSDictionary *contact = self.contacts[[self.tableView indexPathForSelectedRow].row];
        controller.hisID = [contact[@"UserID"] integerValue];
        controller.hisAvatarURL = [NSURL URLWithString:contact[@"AvatarURL"]];
        controller.hisNickname = contact[@"Nickname"];
    }
}

@end
