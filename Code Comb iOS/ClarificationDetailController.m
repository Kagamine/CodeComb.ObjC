//
//  ClarificationDetailController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-12.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "ClarificationDetailController.h"
#import "WebAPI.h"

@interface ClarificationDetailController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *txtQuestion;
@property (weak, nonatomic) IBOutlet UITextView *txtAnswer;
- (IBAction)save:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end

@implementation ClarificationDetailController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.clarification[@"Category"];
    self.txtQuestion.text = self.clarification[@"Question"];
    self.txtAnswer.text = self.clarification[@"Answer"];
    
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

- (IBAction)save:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"可见范围" message:@"您希望哪些人可以看到您的回答？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"所有人",@"仅提问者", nil] show];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.txtAnswer resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    NSInteger status = -1;
    if ([title isEqualToString:@"所有人"]) {
        status = 2;
        [self.clarification setValue:@"BroadCast" forKey:@"Status"];
    } else if ([title isEqualToString:@"仅提问者"]) {
        status = 1;
        [self.clarification setValue:@"Private" forKey:@"Status"];
    }
    
    if (status != -1) {
        [self.clarification setValue:self.txtAnswer.text forKey:@"Answer"];
        
        [WebAPI responseClarification:[self.clarification[@"ClarID"] integerValue] answer:self.txtAnswer.text status:status completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
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
