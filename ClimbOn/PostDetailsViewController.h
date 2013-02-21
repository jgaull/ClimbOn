//
//  PostDetailsViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/21/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PostDetailsViewController : UIViewController

@property (strong, nonatomic) PFObject *postData;

@end
