//
//  FollowUserCell.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/18/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "FollowUserCell.h"

@implementation FollowUserCell

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

-(void)dealloc {
    self.followButton = nil;
    self.userNameLabel = nil;
}

@end
