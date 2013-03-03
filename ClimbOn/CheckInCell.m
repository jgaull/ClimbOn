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
        
        self.postTextLabel.text = [self.postData objectForKey:@"userText"];
        self.dateLabel.text = [self.postData objectForKey:@"createdAt"];
    }
}

- (void)setRouteData:(PFObject *)routeData {
    if (_routeData != routeData) {
        _routeData = routeData;
        
        [self redraw];
    }
}

- (void)setRatingData:(PFObject *)ratingData {
    if (_ratingData != ratingData) {
        _ratingData = ratingData;
        
        [self redraw];
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

- (void)redraw {
    self.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [self.routeData objectForKey:@"name"], [self.ratingData objectForKey:@"name"]];
}

@end
