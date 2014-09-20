//
//  ClarificationListController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-12.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "ClarificationListController.h"
#import "WebAPI.h"
#import "ClarificationDetailController.h"

@interface ClarificationListController ()

@property (strong) NSArray *clarifications;

@end

@implementation ClarificationListController

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
    
    self.clarifications = [NSArray array];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = self.contestTitle;
}

- (void)viewDidAppear:(BOOL)animated
{
    [WebAPI getClarificationsOfContest:self.contestID completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"加载失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.clarifications = data[@"List"];
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
    return self.clarifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *clarification = self.clarifications[indexPath.row];
    
    UITableViewCell *cell;
    if ([clarification[@"Status"] isEqualToString:@"Pending"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Pending" forIndexPath:indexPath];
    } else if ([clarification[@"Status"] isEqualToString:@"Private"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Private" forIndexPath:indexPath];
    } else if ([clarification[@"Status"] isEqualToString:@"BroadCast"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Broadcast" forIndexPath:indexPath];
    } else {
        NSLog(@"Illegal status of clarification: %@", clarification[@"Status"]);
        return nil;
    }
    
    cell.textLabel.text = clarification[@"Question"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"Detail" sender:indexPath];
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
    if ([[segue identifier] isEqualToString:@"Detail"]) {
        ClarificationDetailController *controller = [segue destinationViewController];
        NSInteger index = [self.tableView indexPathForSelectedRow].row;
        controller.clarification = self.clarifications[index];
    }
}

@end
