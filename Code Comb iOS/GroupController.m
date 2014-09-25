//
//  GroupController.m
//  Code Comb iOS
//
//  Created by Gasai Yuno on 14-9-23.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "GroupController.h"
#import "GroupChatController.h"
#import "WebAPI.h"
#import "QuartzCore/QuartzCore.h"

@interface GroupController ()

@property (strong) NSMutableArray *images;
@property (strong) NSMutableArray *groups;
@property (assign) NSInteger page;
@property (assign) BOOL loadOver;

@end

@implementation GroupController

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
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self loadMore];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)startDownloadImageFrom:(NSURL*)url forIndex:(NSInteger)index
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.images setObject:[UIImage imageWithData:data] atIndexedSubscript:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }] resume];
}

- (void)loadMore
{
    if (self.loadOver) {
        return;
    }
    
    NSInteger page = self.page;
    [WebAPI getGroups:page completitionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"加载失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.page = page + 1;
        if (page == 0) {
            self.groups = data[@"List"];
        } else {
            [self.groups addObjectsFromArray:data[@"List"]];
        }
        
        if ([data[@"List"] count] == 0) {
            self.loadOver = YES;
        }
        self.images = [NSMutableArray arrayWithCapacity:self.groups.count];
        for (NSInteger i = 0; i < self.groups.count; i++) {
            [self.images addObject:[NSNull null]];
            [self startDownloadImageFrom:[NSURL URLWithString:self.groups[i][@"Icon"]] forIndex:i];
        }
        [self.tableView reloadData];
    }];
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
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Group" forIndexPath:indexPath];
    
    NSDictionary *group = self.groups[indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = group[@"Title"];
    UIImageView *avatar = (UIImageView*)[cell viewWithTag:100];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 20.0;

    if (self.images[indexPath.row] == [NSNull null]) {
        NSLog(@"missing icon");
        avatar.image = nil;
    } else {
        NSLog(@"icon found");
        avatar.image = self.images[indexPath.row];
    }
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupChat"]) {
        UINavigationController *nav = segue.destinationViewController;
        GroupChatController *controller = (GroupChatController *)[nav topViewController];
        NSDictionary *group = self.groups[[self.tableView indexPathForSelectedRow].row];
        controller.groupID = [group[@"ID"] integerValue];
        controller.groupName = group[@"Title"];
    }
}

@end
