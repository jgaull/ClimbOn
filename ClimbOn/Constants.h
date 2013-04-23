//
//  Constants.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/22/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject


#pragma mark - NSUserDefaults
extern NSString *const kClassPost;
extern NSString *const kClassUser;
extern NSString *const kClassComment;
extern NSString *const kClassEvent;
extern NSString *const kClassRole;
extern NSString *const kClassMedia;
extern NSString *const kClassRating;
extern NSString *const kClassSocialNetworkId;

#pragma mark - Parse Object Generic Keys
extern NSString *const kKeyCreatedAt;
extern NSString *const kKeyUpdatedAt;
extern NSString *const kKeyACL;

#pragma mark - Parse Object Post Key Names
extern NSString *const kKeyPostCreator;
extern NSString *const kKeyPostPhoto;
extern NSString *const kKeyPostRoute;
extern NSString *const kKeyPostType;
extern NSString *const kKeyPostUserText;

#pragma mark - Parse Object Post Key Names
extern NSString *const kKeyUserUsername;
extern NSString *const kKeyUserPassword;
extern NSString *const kKeyUserauthData;
extern NSString *const kKeyUserEmailVerified;
extern NSString *const kKeyUserEmail;
extern NSString *const kKeyUserFirstName;
extern NSString *const kKeyUserLastName;
extern NSString *const kKeyUserLocation;
extern NSString *const kKeyUserProfilePicture;

@end
