//
//  CheckInCell.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "CheckInCell.h"
#import "CheckInViewController.h"

@interface CheckInCell ()

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *postTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet PFImageView *userProfilePic;

@end

@implementation CheckInCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPostData:(PFObject *)postData {
    if (_postData != postData) {
        _postData = postData;
        
        self.postTextLabel.text = [CheckInCell getTagListStringFromPost:self.postData];
        self.dateLabel.text = [self.postData objectForKey:@"createdAt"];
    }
}

- (void)setCreator:(PFUser *)creator {
    if (_creator != creator) {
        _creator = creator;
        
        self.userProfilePic.file = [self.creator objectForKey:@"profilePicture"];
        [self.userProfilePic loadInBackground];
        
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.creator objectForKey:@"firstName"], [self.creator objectForKey:@"lastName"]];
    }
}

- (void)setRouteData:(PFObject *)routeData {
    if (_routeData != routeData) {
        _routeData = routeData;
        
        [self showRouteName];
    }
}

- (void)setRatingData:(PFObject *)ratingData {
    if (_ratingData != ratingData) {
        _ratingData = ratingData;
        
        [self showRouteName];
    }
}

- (void)showRouteName {
    self.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [self.routeData objectForKey:@"name"], [self.ratingData objectForKey:@"name"]];
}

+ (NSString *)getTagListStringFromPost:(PFObject *)postData {
    NSString *tagList = @"";
    for (PFObject *tag in [postData objectForKey:@"tags"]) {
        if ([tagList isEqualToString:@""]) {
            tagList = [tag objectForKey:@"name"];
        }
        else {
            tagList = [NSString stringWithFormat:@"%@, %@", tagList, [tag objectForKey:@"name"]];
        }
    }
    
    return tagList;
}

+ (CGFloat)getHeightForCellFromPostData:(PFObject *)postData {
    CGSize constraint = CGSizeMake(295, 83);
    CGSize size = [[CheckInCell getTagListStringFromPost:postData] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 70;
}

@end
