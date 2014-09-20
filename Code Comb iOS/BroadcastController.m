//
//  BroadcastController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-14.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "BroadcastController.h"
#import "WebAPI.h"

@interface BroadcastController ()

@property (weak, nonatomic) IBOutlet UITextView *txtMessage;

- (IBAction)push:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end

@implementation BroadcastController

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
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)push:(id)sender {
    NSString *message = self.txtMessage.text;
    [WebAPI broadcast:message completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"推送失败" message:info delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            return;
        }
        
        [[[UIAlertView alloc] initWithTitle:@"推送成功" message:@"消息推送成功" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        self.txtMessage.text = @"";
    }];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.txtMessage resignFirstResponder];
}

#define kTabbarHeight 49

- (void)keyboardWillShow:(NSNotification*)n
{
    CGRect frame = self.view.frame;
    frame.size.height-=[[n userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height - kTabbarHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)n
{
    CGRect frame = self.view.frame;
    frame.size.height+=[[n userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height - kTabbarHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.view.frame = frame;
    [UIView commitAnimations];
}
@end
