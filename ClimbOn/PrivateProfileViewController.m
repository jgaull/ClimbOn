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
#import "Constants.h"
#import <Parse/Parse.h>

@interface PrivateProfileViewController ()

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logInButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *profileTable;
@property (weak, nonatomic) IBOutlet PFImageView *profilePhoto;
@property (strong, nonatomic) IBOutlet UIButton *topOutsButton;


@end

@implementation PrivateProfileViewController

- (void)viewDidLoad {

	PFUser *user = [PFUser currentUser];
    if (user) {
		
		PFQuery *query = [[PFQuery alloc] initWithClassName:kClassPost];
		[query whereKey:kKeyPostCreator equalTo:user];
		self.query = query;

        self.profilePhoto.file = [user objectForKey:kKeyUserProfilePicture];
        [self.profilePhoto loadInBackground];
        
        self.locationLabel.text = [user objectForKey:kKeyUserLocation];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:kKeyUserFirstName], [user objectForKey:kKeyUserLastName]];
        
        PFQuery *topOutsQuery = [ClimbOnUtils getScoringEventsForUser:[PFUser currentUser]];
		NSDate *thirtyDaysAgo = [[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
		[topOutsQuery whereKey:kKeyCreatedAt greaterThan:thirtyDaysAgo];
		[topOutsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			NSMutableArray *sends = [[NSMutableArray alloc] init];
			NSMutableArray *flashes = [[NSMutableArray alloc] init];
            NSMutableArray *worked = [[NSMutableArray alloc] init];
            
			for (PFObject *topOutPost in objects) {
				NSInteger type = [[topOutPost objectForKey:kKeyPostType] integerValue];
				if (type == kPostTypeSended) {
					[sends addObject:topOutPost];
				}
				else if (type == kPostTypeFlashed) {
					[flashes addObject:topOutPost];
				}
                else if (type == kPostTypeWorked) {
                    [worked addObject:topOutPost];
                }
			}
            
            NSString *buttonTitle = [NSString stringWithFormat:@"Score: %d", sends.count * kPointsSended + flashes.count * kPointsFlashed + worked.count * kPointsWorked];
			[self.topOutsButton setTitle:buttonTitle forState:UIControlStateNormal];
            
			NSLog(@"Flashes: %d, Sends: %d", flashes.count, sends.count);
		}];
	}

	[super viewDidLoad];
	
    self.title = @"Profile";
	[self.logInButton setTitle:@"Log Out"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogInButton:(id)sender {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFUser logOut];
        self.locationLabel.text = @"";
        self.userNameLabel.text = @"";

        [self performSegueWithIdentifier:@"firstLogin" sender:self];
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
