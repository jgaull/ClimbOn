//
//  Constants.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/22/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - Segue Names: Post Details
extern NSString *const kSegueRoute;
extern NSString *const kSeguePrivateProfile;
extern NSString *const kSeguePublicProfile;

#pragma mark - Notifications
extern NSString *const kNotificationPostDidSave;

#pragma mark - NSUserDefaults
extern NSString *const kClassPost;
extern NSString *const kClassUser;
extern NSString *const kClassComment;
extern NSString *const kClassEvent;
extern NSString *const kClassRole;
extern NSString *const kClassRating;
extern NSString *const kClassSocialNetworkId;
extern NSString *const kClassRoute;

#pragma mark - Parse Object Generic Keys
extern NSString *const kKeyCreatedAt;
extern NSString *const kKeyUpdatedAt;
extern NSString *const kKeyACL;

#pragma mark - Parse Object Post Key Names
extern NSString *const kKeyPostCreator;
extern NSString *const kKeyPostPhotoFile;
extern NSString *const kKeyPostRoute;
extern NSString *const kKeyPostType;
extern NSString *const kKeyPostUserText;

#pragma mark - Parse Object User Key Names
extern NSString *const kKeyUserUsername;
extern NSString *const kKeyUserPassword;
extern NSString *const kKeyUserauthData;
extern NSString *const kKeyUserEmailVerified;
extern NSString *const kKeyUserEmail;
extern NSString *const kKeyUserFirstName;
extern NSString *const kKeyUserLastName;
extern NSString *const kKeyUserLocation;
extern NSString *const kKeyUserProfilePicture;
extern NSString *const kKeyUserFollowing;

#pragma mark - Parse Object Comment Key Names
extern NSString *const kKeyCommentCommentText;
extern NSString *const kKeyCommentCreator;

#pragma mark - Parse Object Event Key Names
extern NSString *const kKeyEventToUser;
extern NSString *const kKeyEventFromUser;
extern NSString *const kKeyEventPost;
extern NSString *const kKeyEventType;

#pragma mark - Parse Object Rating Key Names
extern NSString *const kKeyRatingClimbingType;
extern NSString *const kKeyRatingDifficulty;
extern NSString *const kKeyRatingName;
extern NSString *const kKeyRatingRatingPriority;
extern NSString *const kKeyRatingRatingSystem;

#pragma mark - Parse Object Social Network Id Key Names
extern NSString *const kKeySocialNetworkIdClimbOnId;
extern NSString *const kKeySocialNetworkIdNetworkId;
extern NSString *const kKeySocialNetworkIdNetworkType;

#pragma mark - Parse Object Installation Key Names
extern NSString *const kKeyInstallationAppName;
extern NSString *const kKeyInstallationAppVersion;
extern NSString *const kKeyInstallationParseVersion;
extern NSString *const kKeyInstallationChannels;

#pragma mark - Parse Object Route Key Names
extern NSString *const kKeyRouteCreator;
extern NSString *const kKeyRouteFirstAscent;
extern NSString *const kKeyRouteLocation;
extern NSString *const kKeyRouteName;
extern NSString *const kKeyRouteRating;

@end
