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
#import "CheckInViewController.h"
#import "PostDetailsViewController.h"

#import <Parse/Parse.h>

@interface FeedViewController ()

@property (nonatomic, strong) NSArray *data;
@property (nonatomic) NSInteger *postType;
@property (nonatomic, strong) NSMutableDictionary *commentsLookup;

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
    
    self.title = @"Feed";
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
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
    PFObject *postData = [self.data objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = @"fullCheckinCell";
    CheckInCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.creator = [postData objectForKey:@"creator"];
    cell.routeData = [postData objectForKey:@"route"];
    cell.ratingData = [cell.routeData objectForKey:@"rating"];
    cell.comments = [self.commentsLookup objectForKey:postData.objectId];
    cell.postData = postData;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *postData = [self.data objectAtIndex:indexPath.row];
    return [CheckInCell getHeightForCellFromPostData:postData andComments:[self.commentsLookup objectForKey:postData.objectId]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostDetails"]) {
        PostDetailsViewController *postDetails = (PostDetailsViewController *)segue.destinationViewController;
        postDetails.postData = [self.data objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    
    [super prepareForSegue:segue sender:sender];
}

- (void)refresh {
    self.commentsLookup = [[NSMutableDictionary alloc] init];
    
    PFQuery *feedQuery = [PFQuery queryWithClassName:@"Post"];
    [feedQuery whereKey:@"creator" containedIn:[[PFUser currentUser] objectForKey:@"following"]];
    [feedQuery includeKey:@"creator"];
    [feedQuery includeKey:@"route"];
    [feedQuery includeKey:@"route.rating"];
    [feedQuery includeKey:@"tags"];
    [feedQuery orderByDescending:@"createdAt"];
    [feedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.data = [[NSArray alloc] initWithArray:objects];
            
            for (PFObject *post in objects) {
                PFRelation *comments = [post objectForKey:@"comments"];
                [comments.query includeKey:@"creator"];
                [comments.query orderByAscending:@"createdAt"];
                comments.query.limit = 5;
                
                [comments.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        [self.commentsLookup setObject:[[NSArray alloc] initWithArray:objects] forKey:post.objectId];
                        [self.tableView reloadData];
                    }
                }];
            }
        }
        else {
            NSLog(@"Dag, an error");
        }
        
        [self.refreshControl endRefreshing];
    }];
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
