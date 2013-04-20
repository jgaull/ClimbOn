//
//  FindFriendsViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/18/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "FollowUserCell.h"

#import <Parse/Parse.h>

@interface FindFriendsViewController ()

@property (nonatomic, strong) NSArray *data;

@end

@implementation FindFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *requestPath = @"me?fields=friends.fields(installed,id)";
    
    // Send request to Facebook
    PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            
            NSArray *friends = userData[@"friends"][@"data"];
            NSMutableArray *friendIds = [[NSMutableArray alloc] init];
            
            for (id friend in friends) {
                if (friend[@"installed"]) {
                    [friendIds addObject:friend[@"id"]];
                }
            }
            
            PFQuery *query = [PFQuery queryWithClassName:@"SocialNetworkId"];
            [query whereKey:@"networkType" equalTo:@"facebook"];
            [query whereKey:@"networkId" containedIn:friendIds];
            [query includeKey:@"climbOnId"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSMutableArray *users = [[NSMutableArray alloc] init];
                    for (PFObject *socialNetworkData in objects) {
                        [users addObject:[socialNetworkData objectForKey:@"climbOnId"]];
                    }
                    
                    self.data = [[NSArray alloc] initWithArray:users];
                    [self.tableView reloadData];
                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)populateFriendsArray {
    
}

-(void)dealloc {
    self.data = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"user";
    FollowUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    PFUser *userDataForRow = [self.data objectAtIndex:indexPath.row];
    
    if ([self isFollowingUser:userDataForRow]) {
        [cell.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else {
        [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    
    cell.followButton.tag = indexPath.row;
    cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [userDataForRow objectForKey:@"firstName"], [userDataForRow objectForKey:@"lastName"]];
    
    return cell;
}

- (IBAction)onFollowButton:(UIButton *)sender {
    PFUser *userDataForRow = [self.data objectAtIndex:sender.tag];
    NSMutableArray *currentlyFollowing = [[NSMutableArray alloc] initWithArray:[[PFUser currentUser] objectForKey:@"following"]];

	//set loading state
	[sender setTitle:@"..." forState:UIControlStateNormal];

	if ([self isFollowingUser:userDataForRow]) {
		for(PFUser *user in currentlyFollowing){
			if([user.objectId isEqualToString:userDataForRow.objectId])
			{
				[currentlyFollowing removeObject:user];
				continue;
			}
		}
	}
	else {
		[currentlyFollowing addObject:userDataForRow];
	}
//[{"__type":"Pointer","className":"_User","objectId":"aYNUfEsASm"},{"__type":"Pointer","className":"_User","objectId":"lo4x6cHeHy"}]
    [[PFUser currentUser] setObject:currentlyFollowing forKey:@"following"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
			NSString *newButtonTitle;
			NSString *channelName = [NSString stringWithFormat:@"user_%@", [userDataForRow objectId]];
			PFInstallation *installation = [PFInstallation currentInstallation];
			if ([self isFollowingUser:userDataForRow]) {
				// followed user
				// add to channel
				[installation addUniqueObject:channelName forKey:@"channels"];
				[installation saveEventually];

				newButtonTitle = @"Unfollow";
			}
			else {
				// unfollowed user
				// remove from channel
				[installation removeObject:channelName forKey:@"channels"];
				[installation saveEventually];

				newButtonTitle = @"Follow";
			}
			//update button title
            [sender setTitle:newButtonTitle forState:UIControlStateNormal];
        }
        else {
            NSLog(@"Error following or unfollowing user: %@", error.localizedDescription);
        }
    }];
}

- (BOOL)isFollowingUser:(PFUser *)user {
    NSArray *following = [[NSArray alloc] initWithArray:[[PFUser currentUser] objectForKey:@"following"]];
    for (PFUser *followingUser in following) {
        if ([followingUser.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
