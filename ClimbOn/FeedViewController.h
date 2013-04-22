//
//  FeedViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FeedViewController : PFQueryTableViewController <UITextFieldDelegate>

@property (strong, nonatomic) PFQuery* query;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

//- (BOOL)textFieldShouldReturn:(UITextField *)textField;
//- (BOOL)shouldAutorotate;

@end
