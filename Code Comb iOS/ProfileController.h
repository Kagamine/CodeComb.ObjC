//
//  ProfileController.h
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-20.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface ProfileController : UITableViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    
}
@property (nonatomic, strong) UIImageView * line;
@end
