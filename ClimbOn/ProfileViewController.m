//
//  SecondViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "ProfileViewController.h"
#import "FolloweeCell.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *profileTable;
@property (weak, nonatomic) IBOutlet PFImageView *profilePhoto;
@property (strong, nonatomic) NSArray *followees;
@property (strong, nonatomic) NSMutableDictionary *followeesById;
@property (strong, nonatomic) IBOutlet UIButton *topOutsButton;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.profileTable.dataSource = self;
	self.profileTable.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.profilePhoto.file = [[PFUser currentUser] objectForKey:@"profilePicture"];
        [self.profilePhoto loadInBackground];
        
        PFUser *user = [PFUser currentUser];
        self.locationLabel.text = [user objectForKey:@"location"];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"firstName"], [user objectForKey:@"lastName"]];
        
        [self.logInButton setTitle:@"Log Out" forState:UIControlStateNormal];

		NSMutableArray *followeeIds = [[NSMutableArray alloc] init];
		for (PFUser *followee in [user objectForKey:@"following"]) {
			[followeeIds addObject:followee.objectId];
		}
		PFQuery *followeeQuery = [PFQuery queryWithClassName:@"_User"];
		[followeeQuery whereKey:@"objectId" containedIn:followeeIds];
		[followeeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if(!error) {
				self.followees = objects;
				[self.profileTable reloadData];
			} else {
				NSLog(@"error getting friends %@", error);
			}
		}];
        
        PFQuery *topOutsQuery = [[PFQuery alloc] initWithClassName:@"Post"];
        [topOutsQuery whereKey:@"creator" equalTo:[PFUser currentUser]];
        [topOutsQuery whereKey:@"type" equalTo:@"send"];
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
    self.topOutsButton = nil;
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FolloweeCell";
    FolloweeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...

    PFUser *userDataForRow = [self.followees objectAtIndex:indexPath.row];

    cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [userDataForRow objectForKey:@"firstName"], [userDataForRow objectForKey:@"lastName"]];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.followees.count;
}

@end
