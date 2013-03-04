//
//  CheckInCommentCell.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 3/3/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckInCommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

@end
