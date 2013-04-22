//
//  ProfileViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "PrivateProfileViewController.h"
#import "FolloweeCell.h"
#import "ClimbOnUtils.h"
#import "LikeCell.h"
#import "PostImageCell.h"
#import "CheckInHeadingCell.h"
#import <Parse/Parse.h>

@interface PrivateProfileViewController ()

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *profileTable;
@property (weak, nonatomic) IBOutlet PFImageView *profilePhoto;
@property (strong, nonatomic) IBOutlet UIButton *topOutsButton;


@end

@implementation PrivateProfileViewController

- (void)viewDidLoad {

	PFUser *user = [PFUser currentUser];
    if (user) {
		
		PFQuery *query = [[PFQuery alloc] initWithClassName:@"Post"];
		[query whereKey:@"creator" equalTo:user];
		self.query = query;

        self.profilePhoto.file = [user objectForKey:@"profilePicture"];
        [self.profilePhoto loadInBackground];
        
        self.locationLabel.text = [user objectForKey:@"location"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"firstName"], [user objectForKey:@"lastName"]];
        
        [self.logInButton setTitle:@"Log Out" forState:UIControlStateNormal];
        
        PFQuery *topOutsQuery = [ClimbOnUtils getTopoutsQueryForUser:[PFUser currentUser]];
        NSDate *thirtyDaysAgo = [[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
        [topOutsQuery whereKey:@"createdAt" greaterThan:thirtyDaysAgo];
        [topOutsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *sends = [[NSMutableArray alloc] init];
            NSMutableArray *flashes = [[NSMutableArray alloc] init];
            
            for (PFObject *topOutPost in objects) {
                NSInteger type = [[topOutPost objectForKey:@"type"] integerValue];
                if (type == 0) {
                    [sends addObject:topOutPost];
                }
                else {
                    [flashes addObject:topOutPost];
                }
            }
            
            [self.topOutsButton setTitle:[NSString stringWithFormat:@"Score: %d", sends.count + flashes.count * 10] forState:UIControlStateNormal];
            
            NSLog(@"Flashes: %d, Sends: %d", flashes.count, sends.count);
        }];
    }

	[super viewDidLoad];
	
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
    self.topOutsButton = nil;
}

@end
