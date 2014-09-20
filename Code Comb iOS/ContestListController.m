//
//  ContestListController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-11.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "ContestListController.h"
#import "WebAPI.h"
#import "ClarificationListController.h"

@interface ContestListController ()

@property (strong) NSMutableArray *contests;
@property (assign) NSInteger page;
@property (assign) BOOL loadOver;

@end

@implementation ContestListController

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
    
    self.contests = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.page = 0;
    self.loadOver = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadMore];
}

- (void)loadMore
{
    if (self.loadOver) {
        return;
    }
    
    NSInteger page = self.page;
    [WebAPI getContestsInPage: page completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"加载失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.page = page + 1;
        if (page == 0) {
            self.contests = data[@"List"];
        } else {
            [self.contests addObjectsFromArray:data[@"List"]];
        }
        
        if ([data[@"List"] count] == 0) {
            self.loadOver = YES;
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
    return self.contests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.contests.count - 1) {
        [self loadMore];
    }
    
    NSDictionary *contest = self.contests[indexPath.row];
    
    NSDate *begin = [WebAPI deserializeJsonDateString:contest[@"Begin"]];
    NSDate *end = [WebAPI deserializeJsonDateString:contest[@"End"]];
    
    UITableViewCell *cell;
    if ([begin compare:[NSDate date]] == NSOrderedDescending) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Pending" forIndexPath:indexPath];
    } else if ([end compare:[NSDate date]] == NSOrderedAscending) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Ended" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Live" forIndexPath:indexPath];
    }
    
    cell.textLabel.text = contest[@"Title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowClars" sender:indexPath];
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
    if ([[segue identifier] isEqualToString:@"ShowClars"]) {
        ClarificationListController *controller = [segue destinationViewController];
        NSInteger index = [self.tableView indexPathForSelectedRow].row;
        controller.contestID = [self.contests[index][@"ContestID"] integerValue];
        controller.contestTitle = self.contests[index][@"Title"];
    }
}

@end
