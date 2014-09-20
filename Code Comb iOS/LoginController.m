//
//  LoginController.m
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-11.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import "LoginController.h"
#import "WebAPI.h"
#import "AppDelegate.h"

@interface LoginController () <UITextFieldDelegate>

- (IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UISwitch *swRememberPassword;

@end

@implementation LoginController

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [WebAPI authWithUsername:self.txtUsername.text password:self.txtPassword.text completionHandler:^(NSInteger code, BOOL success, NSString *info, id data) {
        if (success) {
            // Send device token to server
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.deviceToken != nil) {
                [WebAPI registerPushServiceWithDeviceToken:app.deviceToken completionHandler:nil];
            }
            
            [self performSegueWithIdentifier:@"Login" sender:sender];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"登录失败" message:@"用户名或密码错误" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUsername) {
        [self.txtPassword becomeFirstResponder];
    } else if (textField == self.txtPassword) {
        [self.txtPassword resignFirstResponder];
        [self login:nil];
    }
    return YES;
}

@end
