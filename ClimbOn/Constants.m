//
//  Constants.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/22/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - Post Types
NSInteger const kPostTypeSended = 0;
NSInteger const kPostTypeFlashed = 1;
NSInteger const kPostTypeWorked = 2;
NSInteger const kPostTypeLapped = 3;

#pragma mark - Scoring
NSInteger const kPointsLapped = 1;
NSInteger const kPointsWorked = 1;
NSInteger const kPointsFlashed = 10;
NSInteger const kPointsSended = 5;

#pragma mark - Post Info Lookup Keys
NSString *const kInfoKeyLikers = @"likers";

#pragma mark - Segue Names
NSString *const kSegueRoute				 = @"viewRoute";
NSString *const kSeguePrivateProfile     = @"viewPrivateProfile";
NSString *const kSeguePublicProfile      = @"viewPublicProfile";

#pragma mark - Notifications
NSString *const kNotificationPostDidSave = @"kNotificationPostDidSave";

#pragma mark - Parse Object Class Names
NSString *const kClassPost               = @"Post";
NSString *const kClassUser               = @"User";
NSString *const kClassComment            = @"Comment";
NSString *const kClassEvent              = @"Event";
NSString *const kClassRole               = @"Role";
NSString *const kClassRating             = @"Rating";
NSString *const kClassSocialNetworkId    = @"SocialNetworkId";
NSString *const kClassInstallation       = @"Installation";
NSString *const kClassRoute              = @"Route";

#pragma mark - Parse Object Generic Keys
NSString *const kKeyCreatedAt    = @"createdAt";
NSString *const kKeyUpdatedAt    = @"updatedAt";
NSString *const kKeyACL          = @"ACL";

#pragma mark - Parse Object Post Key Names
NSString *const kKeyPostCreator     = @"creator";
NSString *const kKeyPostPhotoFile   = @"photo";
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
NSString *const kKeyUserFollowing          = @"following";

#pragma mark - Parse Object Comment Key Names
NSString *const kKeyCommentCommentText  = @"commentText";
NSString *const kKeyCommentCreator      = @"creator";

#pragma mark - Parse Object Event Key Names
NSString *const kKeyEventToUser     = @"creator";
NSString *const kKeyEventFromUser   = @"fromUser";
NSString *const kKeyEventPost       = @"post";
NSString *const kKeyEventType       = @"type";

#pragma mark - Parse Object Rating Key Names
NSString *const kKeyRatingClimbingType      = @"climbingType";
NSString *const kKeyRatingDifficulty        = @"difficulty";
NSString *const kKeyRatingName              = @"name";
NSString *const kKeyRatingRatingPriority    = @"ratingPriority";
NSString *const kKeyRatingRatingSystem      = @"ratingSystem";

#pragma mark - Parse Object Social Network Id Key Names
NSString *const kKeySocialNetworkIdClimbOnId    = @"climbOnId";
NSString *const kKeySocialNetworkIdNetworkId    = @"networkId";
NSString *const kKeySocialNetworkIdNetworkType  = @"networkType";

#pragma mark - Parse Object Installation Key Names
NSString *const kKeyInstallationAppName         = @"appName";
NSString *const kKeyInstallationAppVersion      = @"appVersion";
NSString *const kKeyInstallationParseVersion    = @"parseVersion";
NSString *const kKeyInstallationChannels        = @"channels";

#pragma mark - Parse Object Route Key Names
NSString *const kKeyRouteCreator        = @"creator";
NSString *const kKeyRouteFirstAscent    = @"firstAscent";
NSString *const kKeyRouteLocation       = @"location";
NSString *const kKeyRouteName           = @"name";
NSString *const kKeyRouteRating         = @"rating";

@end
