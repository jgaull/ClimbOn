//
//  CheckInCell.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CheckInCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *postTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userPhotoImage;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) PFObject *postData;
@property (weak, nonatomic) PFObject *routeData;
@property (weak, nonatomic) PFObject *ratingData;
@property (weak, nonatomic) PFUser *creator;

@end
