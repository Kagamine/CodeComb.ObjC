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

@property (weak, nonatomic) IBOutlet UITextView *txtQuestion;
@property (weak, nonatomic) IBOutlet UITextView *txtAnswer;
- (IBAction)save:(id)sender;

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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.clarification[@"Category"];
    self.txtQuestion.text = self.clarification[@"Question"];
    self.txtAnswer.text = self.clarification[@"Answer"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"可见范围" message:@"您希望哪些人可以看到您的回答？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"所有人",@"仅提问者", nil] show];
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
@end
