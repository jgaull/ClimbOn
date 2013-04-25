//
//  Cache.h
//  ClimbOn
//
//  Created by Jon on 4/24/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Cache : NSObject

+ (id)sharedCache;

- (void)unlikePost:(PFObject *)post;
- (void)likePost:(PFObject *)post;
- (NSMutableArray *)getLikersForPost:(PFObject *)post;
- (BOOL)getHasUserLikedPost:(PFObject *)post;
- (NSMutableDictionary *)infoForPost:(PFObject *)post;
- (void)setInfoForPost:(PFObject *)post likers:(NSArray *)likers;

@end
