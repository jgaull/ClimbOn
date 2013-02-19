//
//  SecondViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self displayUserInfo];
    }
    
    self.title = @"Profile";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogInButton:(id)sender {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFUser logOut];
        [self.logInButton setTitle:@"Log in to Facebook" forState:UIControlStateNormal];
        self.locationLabel.text = @"";
        self.userNameLabel.text = @"";
    }
    else {
        // The permissions requested from the user
        NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_location"];
        
        // Login PFUser using Facebook
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            
            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else {
                    NSLog(@"Uh oh. An error occurred: %@", error);
                }
            } else if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self displayUserInfo];
                
            } else {
                NSLog(@"User with facebook logged in!");
                [self displayUserInfo];
            }
        }];
    }
}

- (void)displayUserInfo {
    NSString *requestPath = @"me?fields=friends.fields(installed,id),name,location,first_name,last_name";
    
    // Send request to Facebook
    PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            
            self.locationLabel.text = location;
            self.userNameLabel.text = name;
            
            if ([PFUser currentUser].isNew) {
                PFObject *socialNetworkId = [[PFObject alloc] initWithClassName:@"SocialNetworkId"];
                [socialNetworkId setObject:userData[@"id"] forKey:@"networkId"];
                [socialNetworkId setObject:[PFUser currentUser] forKey:@"climbOnId"];
                [socialNetworkId setObject:@"facebook" forKey:@"networkType"];
                
                [socialNetworkId saveEventually];
                
                NSArray *following = [[NSArray alloc] initWithObjects:[PFUser currentUser], nil];
                [[PFUser currentUser] setObject:following forKey:@"following"];
                [[PFUser currentUser] setObject:userData[@"first_name"] forKey:@"firstName"];
                [[PFUser currentUser] setObject:userData[@"last_name"] forKey:@"lastName"];
                [[PFUser currentUser] saveInBackground];
            }
            
            [self.logInButton setTitle:@"Log Out of Facebook" forState:UIControlStateNormal];
        }
    }];
}

@end
