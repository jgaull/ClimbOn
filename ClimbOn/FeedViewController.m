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
#import "CheckInHeadingCell.h"
#import "CheckinHashtagCell.h"
#import "CheckInCommentCell.h"
#import "CreateCommentCell.h"

#import <Parse/Parse.h>

static const int kStaticHeadersCount = 2;
static const int kStaticFootersCount = 1;

static const int kHeaderCellIndex = 0;
static const int kHashtagCellIndex = 1;

@interface FeedViewController ()

@property (nonatomic, strong) NSArray *data;
@property (nonatomic) NSInteger *postType;
@property (nonatomic, strong) NSMutableDictionary *commentsLookup;

@property (nonatomic) int remainingQueries;

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
    return self.data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getCommentsForPost:[self.data objectAtIndex:section]].count + kStaticHeadersCount + kStaticFootersCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *postData = [self.data objectAtIndex:indexPath.section];
    PFObject *routeData = [postData objectForKey:@"route"];
    PFUser *creator = [postData objectForKey:@"creator"];
    NSArray *comments = [self getCommentsForPost:postData];
    
    NSString *cellIdentifier = [self getCellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([cell isKindOfClass:[CheckInHeadingCell class]]) {
        CheckInHeadingCell *checkinHeadingCell = (CheckInHeadingCell *)cell;
        
        PFObject *rating = [routeData objectForKey:@"rating"];
        
        checkinHeadingCell.userProfilePic.file = [creator objectForKey:@"profilePicture"];
        [checkinHeadingCell.userProfilePic loadInBackground];
        checkinHeadingCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
        checkinHeadingCell.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [routeData objectForKey:@"name"], [rating objectForKey:@"name"]];
    }
    else if ([cell isKindOfClass:[CheckinHashtagCell class]]) {
        CheckinHashtagCell *checkinHashtagCell = (CheckinHashtagCell *)cell;
        checkinHashtagCell.hashtagTextView.text = [self getTagListStringFromPost:postData];
    }
    else if ([cell isKindOfClass:[CheckInCommentCell class]]) {
        CheckInCommentCell *checkinCommentCell = (CheckInCommentCell *)cell;
        cell = checkinCommentCell;
        
        PFObject *comment = [comments objectAtIndex:(indexPath.row - kStaticHeadersCount)];
        PFUser *creator = [comment objectForKey:@"creator"];
        [creator fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            checkinCommentCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
        }];
        
        checkinCommentCell.commentTextView.text = [comment objectForKey:@"commentText"];
    }
    else if ([cell isKindOfClass:[CreateCommentCell class]]) {
        CreateCommentCell *createCommentCell = (CreateCommentCell *)cell;
        createCommentCell.createCommentField.delegate = self;
        createCommentCell.createCommentField.tag = indexPath.section;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize constraint;
    CGSize size;
    PFObject *comment;
    
    PFObject *postData = [self.data objectAtIndex:indexPath.section];
    NSArray *comments = [self getCommentsForPost:postData];
    
    if (indexPath.row == kHeaderCellIndex) {
        return 60;
    }
    else if (indexPath.row == kHashtagCellIndex) {
        constraint = CGSizeMake(280, 50);
        size = [[self getTagListStringFromPost:postData] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 16;
    }
    else if (indexPath.row == comments.count + kStaticHeadersCount) {
        return 48;
    }
    else if (comments.count > 0) {
        comment = [comments objectAtIndex:(indexPath.row - kStaticHeadersCount)];
        constraint = CGSizeMake(280, 100);
        size = [[comment objectForKey:@"commentText"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 21 + 16;
    }
    
    return 0;
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
            self.remainingQueries = objects.count;
            
            for (PFObject *post in objects) {
                PFRelation *comments = [post objectForKey:@"comments"];
                PFQuery *query = comments.query;
                
                [query includeKey:@"creator"];
                [query orderByAscending:@"createdAt"];
                query.limit = 3;
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        
                        [self.commentsLookup setObject:[[NSArray alloc] initWithArray:objects] forKey:post.objectId];
                    }
                    
                    self.remainingQueries--;
                    if (self.remainingQueries == 0) {
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

- (NSString *)getCellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *HeadingCell = @"headingCell";
    static NSString *HashTagCell = @"hashTagCell";
    //static NSString *ImageCell = @"imageCell";
    static NSString *CommentCell = @"commentCell";
    static NSString *WriteCommentCell = @"writeCommentCell";
    
    if (indexPath.row == kHeaderCellIndex) {
        return HeadingCell;
    }
    else if (indexPath.row == kHashtagCellIndex) {
        return HashTagCell;
    }
    else {
        NSArray *comments = [self getCommentsForPost:[self.data objectAtIndex:indexPath.section]];
        if (indexPath.row == comments.count + kStaticHeadersCount) {
            return WriteCommentCell;
        }
        else {
            return CommentCell;
        }
    }
}

- (NSString *)getTagListStringFromPost:(PFObject *)postData {
    NSString *tagList = @"";
    for (PFObject *tag in [postData objectForKey:@"tags"]) {
        if ([tagList isEqualToString:@""]) {
            tagList = [tag objectForKey:@"name"];
        }
        else {
            tagList = [NSString stringWithFormat:@"%@, %@", tagList, [tag objectForKey:@"name"]];
        }
    }
    
    return tagList;
}

- (NSArray *)getCommentsForPost:(PFObject *)post {
    return [self.commentsLookup objectForKey:post.objectId];
}

#pragma Mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (![textField.text isEqualToString:@""]) {
        PFObject *postData = [self.data objectAtIndex:textField.tag];
        
        PFObject *comment = [[PFObject alloc] initWithClassName:@"Comment"];
        [comment setObject:[PFUser currentUser] forKey:@"creator"];
        [comment setObject:textField.text forKey:@"commentText"];
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                PFRelation *relation = [postData objectForKey:@"comments"];
                [relation addObject:comment];
                [postData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        textField.text = nil;
                    }
                }];
            }
        }];
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
