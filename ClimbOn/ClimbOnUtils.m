//
//  ClimbOnUtils.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/20/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "ClimbOnUtils.h"
#import "Constants.h"
#import "Cache.h"

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
		for(PFUser *user in [[PFUser currentUser] objectForKey:kKeyUserFollowing]){
			if([user.objectId isEqualToString:targetUser.objectId])
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

+ (void)savePostInBackground:(PFObject *)post {
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		PFPush *push = [[PFPush alloc] init];
		PFUser *currentUser = [PFUser currentUser];
        PFObject *route = [post objectForKey:kKeyPostRoute];
		NSString *channel = [NSString stringWithFormat:@"user_%@", currentUser.objectId];
		NSString *firstName = [currentUser objectForKey:kKeyUserFirstName];
		NSString *lastName = [currentUser objectForKey:kKeyUserLastName];
		NSString *lastInitial = @"";
        NSString *routeName = [route objectForKey:kKeyRouteName];
		if(lastName.length > 0)
			lastInitial = [NSString stringWithFormat:@"%@. ", [lastName substringToIndex:1]];
		NSString *message = [NSString stringWithFormat:@"%@ %@just checked in to %@!", firstName, lastInitial, routeName];
		[push setChannel:channel];
		[push setMessage:message];
		[push sendPushInBackground];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostDidSave object:nil];
        
        [[Cache sharedCache] setInfoForPost:post likers:[[NSMutableArray alloc] init]];
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
