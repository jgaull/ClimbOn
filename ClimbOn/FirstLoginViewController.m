//
//  FirstLoginViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/18/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "FirstLoginViewController.h"
#import <Parse/Parse.h>

@interface FirstLoginViewController ()

@end

@implementation FirstLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogInButton:(id)sender {
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
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
