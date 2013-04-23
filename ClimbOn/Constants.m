//
//  Constants.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/22/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - Parse Object Class Names
NSString *const kClassPost               = @"Post";
NSString *const kClassUser               = @"User";
NSString *const kClassComment            = @"Comment";
NSString *const kClassEvent              = @"Event";
NSString *const kClassRole               = @"Role";
NSString *const kClassMedia              = @"Media";
NSString *const kClassRating             = @"Rating";
NSString *const kClassSocialNetworkId    = @"SocialNetworkId";

#pragma mark - Parse Object Generic Keys
NSString *const kKeyCreatedAt    = @"createdAt";
NSString *const kKeyUpdatedAt    = @"updatedAt";
NSString *const kKeyACL          = @"ACL";

#pragma mark - Parse Object Post Key Names
NSString *const kKeyPostCreator     = @"creator";
NSString *const kKeyPostPhoto       = @"photo";
NSString *const kKeyPostRoute       = @"route";
NSString *const kKeyPostType        = @"type";
NSString *const kKeyPostUserText    = @"userText";

#pragma mark - Parse Object User Key Names
NSString *const kKeyUserUsername           = @"username";
NSString *const kKeyUserPassword           = @"password";
NSString *const kKeyUserAuthData           = @"authData";
NSString *const kKeyUserEmailVerified      = @"emailVerified";
NSString *const kKeyUserEmail              = @"email";
NSString *const kKeyUserFirstName          = @"firstName";
NSString *const kKeyUserLastName           = @"lastName";
NSString *const kKeyUserLocation           = @"location";
NSString *const kKeyUserProfilePicture     = @"profilePicture";

#pragma mark - Parse Object Comment Key Names
NSString *const kKeyCommentCommentText = @"commentText";
NSString *const kKeyCommentCreator = @"creator";

#pragma mark - Parse Object Event Key Names
NSString *const kKeyEventToUser = @"creator";
NSString *const kKeyEventFromUser = @"fromUser";
NSString *const kKeyEventPost = @"post";
NSString *const kKeyEventType = @"type";

#pragma mark - Parse Object Media Key Names
NSString *const kKeyMediaFile = @"file";

#pragma mark - Parse Object Rating Key Names
NSString *const kKeyRatingClimbingType = @"climbingType";
NSString *const kKeyRatingDifficulty = @"difficulty";
NSString *const kKeyRatingName = @"name";
NSString *const kKeyRatingRatingPriority = @"ratingPriority";
NSString *const kKeyRatingRatingSystem = @"ratingSystem";

@end
