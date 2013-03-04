//
//  CheckInCell.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "CheckInCell.h"
#import "CheckInViewController.h"
#import "CheckInHeadingCell.h"
#import "CheckinHashtagCell.h"

@interface CheckInCell ()

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *postTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet PFImageView *userProfilePic;
@property (strong, nonatomic) IBOutlet UITableView *commentTable;

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
    return size.height + 16 + 61;
}

#pragma Mark Table view Delegate and Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cellIdentifier = @"checkinHeading";
        CheckInHeadingCell *checkinHeadingCell = [self.commentTable dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = checkinHeadingCell;
        
        PFObject *rating = [self.routeData objectForKey:@"rating"];
        
        checkinHeadingCell.userProfilePic.file = [self.creator objectForKey:@"profilePicture"];
        [checkinHeadingCell.userProfilePic loadInBackground];
        
        checkinHeadingCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.creator objectForKey:@"firstName"], [self.creator objectForKey:@"lastName"]];
        checkinHeadingCell.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [self.routeData objectForKey:@"name"], [rating objectForKey:@"name"]];
    }
    else {
        cellIdentifier = @"checkinHashtag";
        
        CheckinHashtagCell *checkinHashtagCell = [self.commentTable dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = checkinHashtagCell;
        checkinHashtagCell.hashtagTextView.text = [CheckInCell getTagListStringFromPost:self.postData];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 61;
    }
    else if (indexPath.row == 1) {
        CGSize constraint = CGSizeMake(280, 50);
        CGSize size = [[CheckInCell getTagListStringFromPost:self.postData] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 16;
    }
    
    return 0;
}

@end
