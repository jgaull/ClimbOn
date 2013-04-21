//
//  ClimbOnUtils.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/20/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ClimbOnUtils : NSObject

+ (PFQuery *)getTopoutsQueryForUser:(PFUser *)user;

@end
