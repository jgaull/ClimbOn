//
//  ClimbOnUtils.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/20/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "ClimbOnUtils.h"
#import "Constants.h"

@implementation ClimbOnUtils

+ (PFQuery *)getTopoutsQueryForUser:(PFUser *)user {
    PFQuery *sendsQuery = [[PFQuery alloc] initWithClassName:kClassPost];
    [sendsQuery whereKey:kKeyPostType equalTo:[NSNumber numberWithInt:0]];
    
    PFQuery *flashesQuery = [[PFQuery alloc] initWithClassName:kClassPost];
    [flashesQuery whereKey:kKeyPostType equalTo:[NSNumber numberWithInt:1]];
    
    
    PFQuery *topOutsQuery = [PFQuery orQueryWithSubqueries:@[sendsQuery, flashesQuery]];
    [topOutsQuery whereKey:kKeyPostCreator equalTo:user];
    
    return topOutsQuery;
}

+(void)toggleFollowRelationship:(PFUser *)targetUser withBlock:(void (^)(BOOL following))completion
{
    NSMutableArray *currentlyFollowing = [[NSMutableArray alloc] initWithArray:[[PFUser currentUser] objectForKey:kKeyUserFollowing]];

	if ([self isFollowingUser:targetUser]) {
		for(PFUser *user in currentlyFollowing){
			if([targetUser.objectId isEqualToString:targetUser.objectId])
			{
				[currentlyFollowing removeObject:user];
				continue;
			}
		}
	}
	else {
		[currentlyFollowing addObject:targetUser];
	}
	//[{"__type":"Pointer","className":"_User","objectId":"aYNUfEsASm"},{"__type":"Pointer","className":"_User","objectId":"lo4x6cHeHy"}]
    [[PFUser currentUser] setObject:currentlyFollowing forKey:kKeyUserFollowing];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		BOOL *following = [ClimbOnUtils isFollowingUser:targetUser];
        if (!error) {
			NSString *channelName = [NSString stringWithFormat:@"user_%@", [targetUser objectId]];
			PFInstallation *installation = [PFInstallation currentInstallation];
			if (following) {
				// followed user
				// add to channel
				[installation addUniqueObject:channelName forKey:kKeyInstallationChannels];
				[installation saveEventually];
			}
			else {
				// unfollowed user
				// remove from channel
				[installation removeObject:channelName forKey:kKeyInstallationChannels];
				[installation saveEventually];
			}
        }
        else {
            NSLog(@"Error following or unfollowing user: %@", error.localizedDescription);
        }
		if (completion) {
			completion(following);
		}
    }];
}

+ (BOOL)isFollowingUser:(PFUser *)user {
    NSArray *following = [[NSArray alloc] initWithArray:[[PFUser currentUser] objectForKey:kKeyUserFollowing]];
    for (PFUser *followingUser in following) {
        if ([followingUser.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }

    return NO;
}

@end
