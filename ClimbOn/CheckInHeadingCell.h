//
//  CheckInHeadingCell.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 3/3/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CheckInHeadingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (strong, nonatomic) IBOutlet PFImageView *userProfilePic;

@end
