//
//  SearchContactDelegate.h
//  Code Comb iOS
//
//  Created by Kaoet on 14-9-20.
//  Copyright (c) 2014年 Code Comb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactListController.h"

@interface SearchContactDelegate : NSObject <UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

- (instancetype)initWithController:(ContactListController*)controller;

@end
