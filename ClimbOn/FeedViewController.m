 //
//  FeedViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "FeedViewController.h"
#import "CheckInCell.h"
#import "NearbyRoutesViewController.h"

#import <Parse/Parse.h>

@interface FeedViewController ()

@property (nonatomic, strong) NSArray *data;
@property (nonatomic) NSInteger *postType;

@end

@implementation FeedViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *feedQuery = [PFQuery queryWithClassName:@"Post"];
    [feedQuery whereKey:@"creator" containedIn:[[PFUser currentUser] objectForKey:@"following"]];
    [feedQuery includeKey:@"creator"];
    [feedQuery includeKey:@"route"];
    [feedQuery orderByDescending:@"createdAt"];
    [feedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.data = [[NSArray alloc] initWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Dag, an error");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckIn";
    CheckInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *postData = [self.data objectAtIndex:indexPath.row];
    PFUser *creator = [postData objectForKey:@"creator"];
    PFObject *route = [postData objectForKey:@"route"];
    cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
    cell.postTextLabel.text = [postData objectForKey:@"userText"];
    cell.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [route objectForKey:@"name"], [route objectForKey:@"rating"]];
    cell.dateLabel.text = [postData objectForKey:@"createdAt"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize constraint = CGSizeMake(295, 83);
    PFObject *postData = [self.data objectAtIndex:indexPath.row];
    CGSize size = [[postData objectForKey:@"userText"] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 70;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"createPost"]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Check In", @"Top Out", nil];
        [actionSheet showInView:self.tabBarController.view];
        
        return NO;
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger postType = buttonIndex;
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        self.postType = postType;
        [self performSegueWithIdentifier:@"createPost" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    NearbyRoutesViewController *nearbyRoutes = (NearbyRoutesViewController *)[navController.viewControllers objectAtIndex:0];
    nearbyRoutes.postType = self.postType;
    
    [super prepareForSegue:segue sender:sender];
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
