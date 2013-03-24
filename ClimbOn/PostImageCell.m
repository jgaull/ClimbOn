//
//  PostImageCell.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 3/4/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "PostImageCell.h"

@implementation PostImageCell

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
    self.postImageView = nil;
}

@end
