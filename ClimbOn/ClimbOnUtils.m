//
//  ClimbOnUtils.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/20/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "ClimbOnUtils.h"

@implementation ClimbOnUtils

+ (PFQuery *)getTopoutsQueryForUser:(PFUser *)user {
    PFQuery *sendsQuery = [[PFQuery alloc] initWithClassName:@"Post"];
    [sendsQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:0]];
    
    PFQuery *flashesQuery = [[PFQuery alloc] initWithClassName:@"Post"];
    [flashesQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:1]];
    
    
    PFQuery *topOutsQuery = [PFQuery orQueryWithSubqueries:@[sendsQuery, flashesQuery]];
    [topOutsQuery whereKey:@"creator" equalTo:user];
    
    return topOutsQuery;
}

@end
