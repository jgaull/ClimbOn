//
//  Cache.m
//  ClimbOn
//
//  Created by Jon on 4/24/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "Cache.h"
#import "Constants.h"

@interface Cache ()

@property (nonatomic, strong) NSCache *cache;

@end


@implementation Cache

#pragma mark - Cache helper methods

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)unlikePost:(PFObject *)post {
    NSMutableArray *likers = [self getLikersForPost:post];
    
    for (PFUser *user in likers) {
        if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
            [likers removeObject:user];
            break;
        }
    }
}

- (void)likePost:(PFObject *)post {
    NSMutableArray *likers = [self getLikersForPost:post];
    [likers addObject:[PFUser currentUser]];
}

- (NSMutableArray *)getLikersForPost:(PFObject *)post {
    NSMutableDictionary *additionalData = [self infoForPost:post];
    return [additionalData objectForKey:kInfoKeyLikers];
}

- (NSMutableDictionary *)infoForPost:(PFObject *)post {
    return [self.cache objectForKey:post.objectId];
}

- (void)setInfoForPost:(PFObject *)post likers:(NSArray *)likers {
    NSString *postId = post.objectId;
    NSMutableArray *likersCopy = [[NSMutableArray alloc] initWithArray:likers];
    NSMutableDictionary *additionalPostInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:likersCopy, kInfoKeyLikers, nil];
    
    [self.cache setObject:additionalPostInfo forKey:postId];
}

- (BOOL)getHasUserLikedPost:(PFObject *)post {
    NSMutableArray *likers = [self getLikersForPost:post];
    for (PFUser *liker in likers) {
        if ([[PFUser currentUser].objectId isEqualToString:liker.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

@end
