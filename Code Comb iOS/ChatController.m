//
//  ChatController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-14.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "ChatController.h"
#import <JSQMessages.h>
#import "WebAPI.h"

@interface ChatController ()

@property (strong) NSDictionary *myProfile;
@property (strong) NSMutableArray *messages;
@property (strong) UIImage *myAvatar;
@property (strong) UIImage *hisAvatar;
@property (nonatomic,strong) UIImageView *outgoingBubble;
@property (nonatomic,strong) UIImageView *incomingBubble;
- (IBAction)back:(id)sender;

@end

@implementation ChatController

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
    self.messages = [NSMutableArray array];
    self.myProfile = @{@"UserID": @0, @"Nickname": @"Me"};
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.outgoingBubble = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubble = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = self.hisNickname;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Funny animation
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    
    // Download his avatar
    [[[NSURLSession sharedSession] dataTaskWithURL:self.hisAvatarURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.hisAvatar = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data] diameter:self.collectionView.collectionViewLayout.incomingAvatarViewSize.width];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }] resume];
    
    // Get my profile
    [WebAPI getProfileWithCompletionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"获取用户信息失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        self.myProfile = data;
        self.sender = self.myProfile[@"Nickname"];
        
        // Download my avatar
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:self.myProfile[@"AvatarURL"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            self.myAvatar = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data] diameter: self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }] resume];
        
        [self.collectionView reloadData];
    }];
    
    // Get chat records
    [WebAPI getChatRecordsWith:self.hisID completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"获取消息记录失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        self.messages = data[@"List"];
        for (NSMutableDictionary *message in self.messages) {
            [message setValue:[WebAPI deserializeJsonDateString:message[@"Time"]] forKey:@"Time"];
        }
        
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.messages.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
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
    [WebAPI sendMessageTo:self.hisID content:text completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"发送失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        NSDictionary *message = @{
                                  @"SenderID": self.myProfile[@"UserID"],
                                  @"ReceiverID": @(self.hisID),
                                  @"Time": date,
                                  @"Content": text
                                  };
        [self.messages addObject:message];
        
        [self finishSendingMessage];
    }];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messages[indexPath.item];
    
    if ([message[@"SenderID"] integerValue] == self.hisID) {
        return [[JSQMessage alloc] initWithText:message[@"Content"] sender:self.hisNickname date:message[@"Time"]];
    } else {
        return [[JSQMessage alloc] initWithText:message[@"Content"] sender:self.myProfile[@"Nickname"] date:message[@"Time"]];
    }
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message[@"SenderID"] integerValue] == self.hisID) {
        return [[UIImageView alloc] initWithImage:self.incomingBubble.image
                                 highlightedImage:self.incomingBubble.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.outgoingBubble.image
                             highlightedImage:self.outgoingBubble.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message[@"SenderID"] integerValue] == self.hisID) {
        return [[UIImageView alloc] initWithImage:self.hisAvatar];
    }
    
    return [[UIImageView alloc] initWithImage:self.myAvatar];
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
    
    if ([msg[@"SenderID"] integerValue] == self.hisID) {
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

@end
