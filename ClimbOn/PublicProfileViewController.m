//
//  PublicProfileViewController.m
//  ClimbOn
//
//  Created by Grant Helton on 4/26/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "PublicProfileViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "ClimbOnUtils.h"

@interface PublicProfileViewController()

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *profileTable;
@property (strong, nonatomic) IBOutlet PFImageView *profilePhoto;
@property (strong, nonatomic) IBOutlet UIButton *topOutsButton;

@end

@implementation PublicProfileViewController

-(void)viewDidLoad {
	if(self.user) {

		PFQuery *query = [[PFQuery alloc] initWithClassName:kClassPost];
		[query whereKey:kKeyPostCreator equalTo:self.user];
		self.query = query;

		self.profilePhoto.file = [self.user objectForKey:kKeyUserProfilePicture];
		[self.profilePhoto loadInBackground];

		self.locationLabel.text = [self.user objectForKey:kKeyUserLocation];
		self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.user objectForKey:kKeyUserFirstName], [self.user objectForKey:kKeyUserLastName]];

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
}
- (IBAction)onTapFollow:(id)sender {
	[ClimbOnUtils toggleFollowRelationship:self.user withBlock:^(BOOL following) {
		UIButton *followButton = (UIButton *)sender;
		NSString *newTitle;
		if (following) {
			newTitle = @"Unfollow";
		} else {
			newTitle = @"Follow";
		}
		[followButton setTitle:newTitle forState:UIControlStateNormal];
	}];
}

-(void)dealloc {
    self.locationLabel = nil;
    self.userNameLabel = nil;
    self.profilePhoto = nil;
	self.user = nil;
	self.profileTable = nil;
	self.topOutsButton = nil;
}

@end
