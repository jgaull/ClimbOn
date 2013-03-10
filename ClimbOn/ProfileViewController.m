//
//  SecondViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profilePhoto;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.profilePhoto.file = [[PFUser currentUser] objectForKey:@"profilePicture"];
        [self.profilePhoto loadInBackground];
        
        PFUser *user = [PFUser currentUser];
        self.locationLabel.text = [user objectForKey:@"location"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"firstName"], [user objectForKey:@"lastName"]];
        
        [self.logInButton setTitle:@"Log Out" forState:UIControlStateNormal];
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
        
        [self performSegueWithIdentifier:@"firstLogin" sender:self];
    }
}

-(void)dealloc {
    self.locationLabel = nil;
    self.logInButton = nil;
    self.userNameLabel = nil;
    self.profilePhoto = nil;
}

@end
