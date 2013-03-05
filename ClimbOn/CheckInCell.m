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
#import "CheckInCommentCell.h"
#import "CreateCommentCell.h"

static const int kStaticHeadersCount = 2;
static const int kStaticFootersCount = 1;

static const int kHeaderCellIndex = 0;
static const int kHashtagCellIndex = 1;

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
        [self.commentTable reloadData];
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

- (void)setComments:(NSArray *)comments {
    if (_comments != comments) {
        _comments = comments;
        
        [self.commentTable reloadData];
    }
}

- (void)showRouteName {
    self.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [self.routeData objectForKey:@"name"], [self.ratingData objectForKey:@"name"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (![textField.text isEqualToString:@""]) {
        PFObject *comment = [[PFObject alloc] initWithClassName:@"Comment"];
        [comment setObject:[PFUser currentUser] forKey:@"creator"];
        [comment setObject:textField.text forKey:@"commentText"];
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                PFRelation *relation = [self.postData objectForKey:@"comments"];
                [relation addObject:comment];
                [self.postData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"Saved the comment");
                        textField.text = nil;
                    }
                }];
            }
        }];
    }
    
    return NO;
}

#pragma Mark Table view Delegate and Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count + kStaticHeadersCount + kStaticFootersCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.row == kHeaderCellIndex) {
        cellIdentifier = @"checkinHeading";
        CheckInHeadingCell *checkinHeadingCell = [self.commentTable dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = checkinHeadingCell;
        
        PFObject *rating = [self.routeData objectForKey:@"rating"];
        
        checkinHeadingCell.userProfilePic.file = [self.creator objectForKey:@"profilePicture"];
        [checkinHeadingCell.userProfilePic loadInBackground];
        
        checkinHeadingCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.creator objectForKey:@"firstName"], [self.creator objectForKey:@"lastName"]];
        checkinHeadingCell.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [self.routeData objectForKey:@"name"], [rating objectForKey:@"name"]];
    }
    else if (indexPath.row == kHashtagCellIndex) {
        cellIdentifier = @"checkinHashtag";
        
        CheckinHashtagCell *checkinHashtagCell = [self.commentTable dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = checkinHashtagCell;
        checkinHashtagCell.hashtagTextView.text = [CheckInCell getTagListStringFromPost:self.postData];
    }
    else if (indexPath.row == self.comments.count + kStaticHeadersCount) {
        cellIdentifier = @"writeComment";
        CreateCommentCell *createCommentCell = [self.commentTable dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = createCommentCell;
        createCommentCell.createCommentField.delegate = self;
    }
    else {
        cellIdentifier = @"checkinComment";
        
        CheckInCommentCell *checkinCommentCell = [self.commentTable dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = checkinCommentCell;
        
        PFObject *comment = [self.comments objectAtIndex:(indexPath.row - kStaticHeadersCount)];
        PFUser *creator = [comment objectForKey:@"creator"];
        [creator fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            checkinCommentCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
        }];
        
        checkinCommentCell.commentTextView.text = [comment objectForKey:@"commentText"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CheckInCell getHeightForcellAtIndexPath:indexPath withPostData:self.postData andComments:self.comments];
}

#pragma Mark Static methods for calculating cell heights

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

+ (CGFloat)getHeightForCellFromPostData:(PFObject *)postData andComments:(NSArray *)comments {
    
    CGFloat size = 0;
    
    for (int i = 0; i < comments.count + kStaticFootersCount + kStaticHeadersCount; i++) {
        size += [CheckInCell getHeightForcellAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] withPostData:postData andComments:comments];
    }
    
    return size;
}

+ (CGFloat)getHeightForcellAtIndexPath:(NSIndexPath *)indexPath withPostData:(PFObject *)postData andComments:(NSArray *)comments {
    
    CGSize constraint;
    CGSize size;
    PFObject *comment;
    
    if (indexPath.row == kHeaderCellIndex) {
        return 60;
    }
    else if (indexPath.row == kHashtagCellIndex) {
        constraint = CGSizeMake(280, 50);
        size = [[CheckInCell getTagListStringFromPost:postData] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 16;
    }
    else if (indexPath.row == comments.count + kStaticHeadersCount) {
        return 40;
    }
    else if (comments.count > 0) {
        comment = [comments objectAtIndex:(indexPath.row - kStaticHeadersCount)];
        constraint = CGSizeMake(280, 100);
        size = [[comment objectForKey:@"commentText"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 21 + 16;
    }
    
    return 0;
}

@end
