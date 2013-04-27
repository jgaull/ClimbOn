//
//  PublicProfileViewController.h
//  ClimbOn
//
//  Created by Grant Helton on 4/26/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FeedViewController.h"

@interface PublicProfileViewController : FeedViewController

@property (strong, nonatomic) PFUser *user;

@end
