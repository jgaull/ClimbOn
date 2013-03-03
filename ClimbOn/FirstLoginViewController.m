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

@property (strong, nonatomic) NSMutableData *profilePicData;

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
            [self fetchUserInfo];
        }
    }];
}

- (void)fetchUserInfo {
    NSString *requestPath = @"me?fields=name,location,first_name,last_name";
    
    // Send request to Facebook
    PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
    
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            
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
                [[PFUser currentUser] setObject:userData[@"location"] forKey:@"location"];
                [[PFUser currentUser] saveInBackground];
                
                [self loadProfilePic:userData[@"id"]];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}

- (void)loadProfilePic:(NSString *)userId {
    self.profilePicData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    // Run network request asynchronously
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConnection start];
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.profilePicData appendData:data]; // Build the image
    self.profilePic.image = [UIImage imageWithData:self.profilePicData];
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    
    self.profilePic.image = [UIImage imageWithData:self.profilePicData];
    
    PFFile *imageFile = [PFFile fileWithName:@"profilePic.jpg" data:self.profilePicData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Create a PFObject around a PFFile and associate it with the current user
            [[PFUser currentUser] setObject:imageFile forKey:@"profilePicture"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error saving image to database: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            // Log details of the failure
            NSLog(@"Error saving image file: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
