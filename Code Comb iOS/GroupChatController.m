//
//  GroupChatController.m
//  Code Comb iOS
//
//  Created by Gasai Yuno on 14-9-24.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//
#import "GroupChatController.h"
#import "GroupProfileController.h"
#import <JSQMessages.h>
#import "WebAPI.h"

@interface GroupChatController ()

@property (strong) NSDictionary *myProfile;
@property (strong) NSMutableArray *messages;
@property (nonatomic,strong) UIImageView *outgoingBubble;
@property (nonatomic,strong) UIImageView *incomingBubble;
@property (nonatomic,strong) UIBarButtonItem *backButton;
@property (strong) NSMutableDictionary *images;

@end

@implementation GroupChatController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.images = [NSMutableDictionary dictionaryWithCapacity:100];
    self.messages = [NSMutableArray array];
    self.myProfile = @{@"UserID": @0, @"Nickname": @"Me"};
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = self.backButton;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.outgoingBubble = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubble = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
}

- (void)downloadImage:(NSURL*)url
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.images setObject:[UIImage imageWithData:data] forKey:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }] resume];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = self.groupName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Funny animation
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    
    // Download his avatar
    /*
    [[[NSURLSession sharedSession] dataTaskWithURL:self.hisAvatarURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.hisAvatar = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data] diameter:self.collectionView.collectionViewLayout.incomingAvatarViewSize.width];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }] resume];
    */
    
    // Get my profile
    [WebAPI getProfileWithCompletionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"获取用户信息失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        self.myProfile = data;
        self.sender = self.myProfile[@"Nickname"];
        
        // Download my avatar
        NSURL *myAvatarURL = [[NSURL alloc] initWithString:self.myProfile[@"AvatarURL"]];
        if(![[self.images allKeys] containsObject:myAvatarURL])
            [self downloadImage:myAvatarURL];
        
        /*
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:self.myProfile[@"AvatarURL"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            self.myAvatar = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data] diameter: self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }] resume];
        */
        [self.collectionView reloadData];
    }];
    
    // Get chat records
    [WebAPI getGroupChat:self.groupID page:0 completitionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"获取消息记录失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.messages = data[@"List"];
        for(int i = 0; i < self.messages.count; i++)
        {
            NSURL *avatarURL = [[NSURL alloc] initWithString:self.messages[i][@"AvatarURL"]];
            if([[self.images allKeys] containsObject:avatarURL])
                continue;
            [self downloadImage:avatarURL];
        }
        for (NSMutableDictionary *message in self.messages) {
            [message setValue:[WebAPI deserializeJsonDateString:message[@"Time"]] forKey:@"Time"];
        }
        
        [self.collectionView reloadData];
        
        if (self.messages.count > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.messages.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    [WebAPI sendGroupMessage:self.groupID message:text completitionHandler:^(NSInteger code, BOOL success, NSString *info, id data)
    {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"发送失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        NSDictionary *message = @{
                                  @"UserID": self.myProfile[@"UserID"],
                                  @"GroupID": @(self.groupID),
                                  @"Time": date,
                                  @"Message": text,
                                  @"AvatarURL": self.myProfile[@"AvatarURL"],
                                  @"Nickname": self.myProfile[@"Nickname"]
                                  };
        [self.messages addObject:message];
        
        [self finishSendingMessage];
    }];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messages[indexPath.item];
    
    if ([message[@"UserID"] integerValue] != [self.myProfile[@"UserID"] integerValue]) {
        return [[JSQMessage alloc] initWithText:message[@"Message"] sender:message[@"Nickname"] date:message[@"Time"]];
    } else {
        return [[JSQMessage alloc] initWithText:message[@"Message"] sender:self.myProfile[@"Nickname"] date:message[@"Time"]];
    }
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message[@"UserID"] integerValue] != [self.myProfile[@"UserID"] integerValue]) {
        return [[UIImageView alloc] initWithImage:self.incomingBubble.image
                                 highlightedImage:self.incomingBubble.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.outgoingBubble.image
                             highlightedImage:self.outgoingBubble.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [self.messages objectAtIndex:indexPath.item];
    UIImage *avatar ;
    NSURL *avatarURL = [[NSURL alloc] initWithString:message[@"AvatarURL"]];
    if([[self.images allKeys] containsObject:[[NSURL alloc] initWithString:message[@"AvatarURL"]]])
    {
        avatar = [self.images objectForKey:avatarURL];
        UIImage *ret = [JSQMessagesAvatarFactory avatarWithImage:avatar diameter:self.collectionView.collectionViewLayout.incomingAvatarViewSize.width];
        return [[UIImageView alloc] initWithImage:ret];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [self.messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message[@"Time"]];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    NSDictionary *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg[@"UserID"] integerValue] != [self.myProfile[@"UserID"] integerValue]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupProfile"]) {
        GroupProfileController *controller = segue.destinationViewController;
        [controller setGroupID:self.groupID];
    }
}

@end