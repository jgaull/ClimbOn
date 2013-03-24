//
//  RouteViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/25/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "FeedViewController.h"

@interface RouteViewController : FeedViewController

@property (nonatomic, strong) PFObject *routeData;

@end
