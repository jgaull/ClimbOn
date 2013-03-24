 //
//  FeedViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "FeedViewController.h"
#import "NearbyRoutesViewController.h"
#import "CheckInViewController.h"
#import "PostDetailsViewController.h"
#import "CheckInHeadingCell.h"
#import "CheckinHashtagCell.h"
#import "CheckInCommentCell.h"
#import "CreateCommentCell.h"
#import "MoreCommentsCell.h"
#import "LikeCell.h"
#import "PostImageCell.h"

#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

static const int kStaticHeadersCount = 3;
static const int kStaticFootersCount = 1;

static const int kHeaderCellIndex = 0;
static const int kHashtagCellIndex = 1;
static const int kLikesCellIndex = 2;

NSString *const HeadingCellIdentifier = @"headingCell";
NSString *const HashTagCellIdentifier = @"hashTagCell";
NSString *const ImageCellIdentifier = @"imageCell";
NSString *const CommentCellIdentifier = @"commentCell";
NSString *const WriteCommentCellIdentifier = @"writeCommentCell";
NSString *const MoreCommentsCellIdentifier = @"moreCommentsCell";
NSString *const LikesCellIdentifier = @"likesCell";

@interface FeedViewController ()

@property (nonatomic, strong) NSMutableArray *postsList;
@property (nonatomic, strong) NSMutableDictionary *commentsLookup;
@property (nonatomic, strong) NSMutableDictionary *userHasLikedLookup;
@property (nonatomic, strong) NSMutableDictionary *numberOfLikesLookup;

@property (nonatomic, strong) NSMutableDictionary *pfImageFileLookup;
@property (nonatomic, strong) NSMutableDictionary *imageLookup;

@property (nonatomic) NSInteger *postType;

@property (nonatomic) int remainingQueries;
//@property (nonatomic) BOOL isPlayingMovie;

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
    
    self.pfImageFileLookup = [[NSMutableDictionary alloc] init];
    self.imageLookup = [[NSMutableDictionary alloc] init];
    //self.isPlayingMovie = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.pfImageFileLookup = [[NSMutableDictionary alloc] init];
    self.imageLookup = [[NSMutableDictionary alloc] init];
}

-(void)dealloc {
    self.postsList = nil;
    self.commentsLookup = nil;
    self.userHasLikedLookup = nil;
    self.numberOfLikesLookup = nil;
    self.postsList = nil;
}

/*- (BOOL)shouldAutorotate {
    return self.isPlayingMovie;
}*/

#pragma mark - Button Listeners

- (IBAction)onMoreCommentsButton:(UIButton *)sender {
    NSInteger section = sender.tag;
    
    PFObject *post = [self.postsList objectAtIndex:section];
    NSMutableArray *comments = [self getCommentsForPost:post];
    
    PFRelation *relation = [post objectForKey:@"comments"];
    PFQuery *query = relation.query;
    [query orderByAscending:@"createdAt"];
    query.limit = 5;
    query.skip = comments.count;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (NSInteger i = comments.count; i < objects.count + comments.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i + kStaticHeadersCount inSection:section]];
            }
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [comments addObjectsFromArray:objects];
            [self.tableView endUpdates];
        }
    }];
}

- (IBAction)onLikeButton:(UIButton *)sender {
    int section = sender.tag;
    PFObject *post = [self.postsList objectAtIndex:section];
    PFRelation *likes = [post objectForKey:@"likes"];
    NSInteger numLikes = [[self.numberOfLikesLookup objectForKey:post.objectId] intValue];
    BOOL hasLiked = [[self.userHasLikedLookup objectForKey:post.objectId] boolValue];
    
    if (hasLiked) {
        [post incrementKey:@"numLikes" byAmount:[NSNumber numberWithInt:-1]];
        [likes removeObject:[PFUser currentUser]];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.userHasLikedLookup setObject:[NSNumber numberWithBool:NO] forKey:post.objectId];
                [self.numberOfLikesLookup setObject:[NSNumber numberWithInt:numLikes - 1] forKey:post.objectId];
                [sender setImage:[UIImage imageNamed:@"likebutton.png"] forState:UIControlStateNormal];
                [self refreshTableViewAtIndexPath:[NSIndexPath indexPathForRow:kLikesCellIndex inSection:section]];
                NSLog(@"Unliked!");
            }
        }];
    }
    else {
        [post incrementKey:@"numLikes"];
        [likes addObject:[PFUser currentUser]];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.userHasLikedLookup setObject:[NSNumber numberWithBool:YES] forKey:post.objectId];
                [self.numberOfLikesLookup setObject:[NSNumber numberWithInt:numLikes + 1] forKey:post.objectId];
                [sender setImage:[UIImage imageNamed:@"likebuttonliked.png"] forState:UIControlStateNormal];
                [self refreshTableViewAtIndexPath:[NSIndexPath indexPathForRow:kLikesCellIndex inSection:section]];
                NSLog(@"Liked!");
            }
        }];
    }
}

/*- (IBAction)onPlayButton:(UIButton *)sender {
    PFObject *post = [self.postsList objectAtIndex:sender.tag];
    PFObject *videoMedia = [post objectForKey:@"video"];
    PFFile *video = [videoMedia objectForKey:@"file"];
    
    NSURL *movieURL = [NSURL URLWithString:video.url];
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidDismiss:) name:MPMoviePlayerPlaybackDidFinishNotification object:movieController.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:movieController];
    
    self.isPlayingMovie = YES;
}*/

/*- (void)moviePlayerDidDismiss:(NSNotification *)note {
    self.isPlayingMovie = NO;
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.postsList.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cellsForImages = [self cellsForImagesInSection:section];
    NSArray *comments = [self getCommentsForPost:[self.postsList objectAtIndex:section]];
    NSInteger cellsForComments = comments.count;
    NSInteger cellsForMore = comments.count > 0 ? 1 : 0;
    
    return kStaticHeadersCount + cellsForImages + cellsForComments + cellsForMore + kStaticFootersCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *postData = [self.postsList objectAtIndex:indexPath.section];
    PFObject *routeData = [postData objectForKey:@"route"];
    PFUser *creator = [postData objectForKey:@"creator"];
    
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
    else if ([cell isKindOfClass:[PostImageCell class]]) {
        PostImageCell *postImageCell = (PostImageCell *)cell;
        //postImageCell.postImageView.file = nil;
        UIImage *image = [self.imageLookup objectForKey:postData.objectId];
        if (!image) {
            PFObject *media = [postData objectForKey:@"photo"];
            PFFile *imageFile = [media objectForKey:@"file"];
            [self.pfImageFileLookup setObject:imageFile forKey:postData.objectId];
            
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *loadedImage = [[UIImage alloc] initWithData:data];
                    [self.imageLookup setObject:loadedImage forKey:postData.objectId];
                    postImageCell.postImageView.image = loadedImage;
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
        else {
            postImageCell.postImageView.image = image;
        }
    }
    else if ([cell isKindOfClass:[CheckInCommentCell class]]) {
        CheckInCommentCell *checkinCommentCell = (CheckInCommentCell *)cell;
        cell = checkinCommentCell;
        
        PFObject *comment = [self getCommentForIndexPath:indexPath];
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
    else if ([cell isKindOfClass:[MoreCommentsCell class]]) {
        MoreCommentsCell *moreCommentsCell = (MoreCommentsCell *)cell;
        moreCommentsCell.moreButton.tag = indexPath.section;
    }
    else if ([cell isKindOfClass:[LikeCell class]]) {
        LikeCell *likeCell = (LikeCell *)cell;
        likeCell.likeButton.tag = indexPath.section;
        likeCell.likesLabel.text = [[self.numberOfLikesLookup objectForKey:postData.objectId] stringValue];
        
        BOOL hasLiked = [[self.userHasLikedLookup objectForKey:postData.objectId] boolValue];
        NSString *buttonImage = hasLiked ? @"likebuttonliked.png" : @"likebutton.png";
        [likeCell.likeButton setImage:[UIImage imageNamed:buttonImage] forState:UIControlStateNormal];
    }
    
    return cell;
}

#pragma mark - Cell finding helper methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize constraint;
    CGSize size;
    PFObject *comment;
    
    PFObject *postData = [self.postsList objectAtIndex:indexPath.section];
    NSString *cellIdentifier = [self getCellIdentifierForIndexPath:indexPath];
    
    if ([HeadingCellIdentifier isEqualToString:cellIdentifier]) {
        return 60;
    }
    else if ([HashTagCellIdentifier isEqualToString:cellIdentifier]) {
        constraint = CGSizeMake(280, 50);
        size = [[self getTagListStringFromPost:postData] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 16;
    }
    else if ([LikesCellIdentifier isEqualToString:cellIdentifier]) {
        return 50;
    }
    else if ([WriteCommentCellIdentifier isEqualToString:cellIdentifier]) {
        return 48;
    }
    else if ([MoreCommentsCellIdentifier isEqualToString:cellIdentifier]) {
        return 24;
    }
    else if ([ImageCellIdentifier isEqualToString:cellIdentifier]) {
        return 181;
    }
    else if ([CommentCellIdentifier isEqualToString:cellIdentifier]) {
        comment = [self getCommentForIndexPath:indexPath];
        constraint = CGSizeMake(280, 100);
        size = [[comment objectForKey:@"commentText"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 21 + 16;
    }
    else {
        NSLog(@"%@ does not have code to calculate its height.", cellIdentifier);
    }
    
    return 0;
}

- (NSString *)getCellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger cellsForImages = [self cellsForImagesInSection:indexPath.section];
    NSArray *comments = [self getCommentsForPost:[self.postsList objectAtIndex:indexPath.section]];
    NSInteger cellsForComments = comments.count;
    NSInteger cellsForMore = comments.count > 0 ? 1 : 0;
    
    if (indexPath.row == kHeaderCellIndex) {
        return HeadingCellIdentifier;
    }
    else if (indexPath.row == kHashtagCellIndex) {
        return HashTagCellIdentifier;
    }
    else if (indexPath.row == kLikesCellIndex) {
        return LikesCellIdentifier;
    }
    else if (indexPath.row == kStaticHeadersCount && cellsForImages >= 1) {
        return ImageCellIdentifier;
    }
    else if (indexPath.row == kStaticHeadersCount + cellsForImages + cellsForComments && cellsForComments > 0) {
        return MoreCommentsCellIdentifier;
    }
    else if (indexPath.row == kStaticHeadersCount + cellsForImages + cellsForComments + cellsForMore) {
            return WriteCommentCellIdentifier;
    }
    else {
        return CommentCellIdentifier;
    }
}

- (NSInteger)cellsForImagesInSection:(NSInteger)section {
    PFObject *post = [self.postsList objectAtIndex:section];
    PFObject *photo = [post objectForKey:@"photo"];
    return photo != nil;
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

- (NSMutableArray *)getCommentsForPost:(PFObject *)post {
    return [self.commentsLookup objectForKey:post.objectId];
}

- (PFObject *)getCommentForIndexPath:(NSIndexPath *)indexPath {
    PFObject *post = [self.postsList objectAtIndex:indexPath.section];
    NSArray *comments = [self getCommentsForPost:post];
    return [comments objectAtIndex:(indexPath.row - kStaticHeadersCount - [self cellsForImagesInSection:indexPath.section])];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostDetails"]) {
        PostDetailsViewController *postDetails = (PostDetailsViewController *)segue.destinationViewController;
        postDetails.postData = [self.postsList objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    
    [super prepareForSegue:segue sender:sender];
}

- (void)refreshTableViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - Handling loading the data.

- (void)refresh {
    self.commentsLookup = [[NSMutableDictionary alloc] init];
    self.userHasLikedLookup = [[NSMutableDictionary alloc] init];
    self.numberOfLikesLookup = [[NSMutableDictionary alloc] init];
    
    PFQuery *feedQuery = [PFQuery queryWithClassName:@"Post"];
    [feedQuery whereKey:@"creator" containedIn:[[PFUser currentUser] objectForKey:@"following"]];
    [feedQuery includeKey:@"creator"];
    [feedQuery includeKey:@"route"];
    [feedQuery includeKey:@"route.rating"];
    [feedQuery includeKey:@"route.media"];
    [feedQuery includeKey:@"tags"];
    [feedQuery includeKey:@"video"];
    [feedQuery includeKey:@"photo"];
    [feedQuery orderByDescending:@"createdAt"];
    feedQuery.limit = 15;
    [feedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.postsList = [[NSMutableArray alloc] initWithArray:objects];
            self.remainingQueries = objects.count;
            
            for (PFObject *post in objects) {
                PFRelation *comments = [post objectForKey:@"comments"];
                PFQuery *commentsQuery = comments.query;
                
                [commentsQuery includeKey:@"creator"];
                [commentsQuery orderByAscending:@"createdAt"];
                commentsQuery.limit = 3;
                
                [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        
                        [self.commentsLookup setObject:[[NSMutableArray alloc] initWithArray:objects] forKey:post.objectId];
                    }
                    
                    self.remainingQueries--;
                    if (self.remainingQueries == 0) {
                        [self.tableView reloadData];
                    }
                }];
                
                PFRelation *likes = [post objectForKey:@"likes"];
                PFQuery *likesQuery = likes.query;
                NSInteger numLikes = [[post objectForKey:@"numLikes"] integerValue];
                
                [self.numberOfLikesLookup setObject:[NSNumber numberWithInt:numLikes] forKey:post.objectId];
                if (numLikes > 0) {
                    [likesQuery getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
                        if (!error) {
                            if (object) {
                                [self.userHasLikedLookup setObject:[NSNumber numberWithBool:YES] forKey:post.objectId];
                                [self.tableView reloadData];
                            }
                            else {
                                [self.userHasLikedLookup setObject:[NSNumber numberWithBool:NO] forKey:post.objectId];
                            }
                        }
                        else {
                            [self.userHasLikedLookup setObject:[NSNumber numberWithBool:NO] forKey:post.objectId];
                        }
                    }];
                }
                else {
                    [self.userHasLikedLookup setObject:[NSNumber numberWithBool:NO] forKey:post.objectId];
                }
            }
        }
        else {
            NSLog(@"Dag, an error");
        }
        
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (![textField.text isEqualToString:@""]) {
        NSInteger section = textField.tag;
        PFObject *postData = [self.postsList objectAtIndex:section];
        
        PFObject *comment = [[PFObject alloc] initWithClassName:@"Comment"];
        [comment setObject:[PFUser currentUser] forKey:@"creator"];
        [comment setObject:textField.text forKey:@"commentText"];
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                PFRelation *relation = [postData objectForKey:@"comments"];
                [postData incrementKey:@"numComments"];
                [relation addObject:comment];
                [postData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        textField.text = nil;
                        
                        NSMutableArray *comments = [self getCommentsForPost:postData];
                        
                        [self.tableView beginUpdates];
                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count + kStaticHeadersCount inSection:section]] withRowAnimation:UITableViewRowAnimationTop];
                        [comments addObject:comment];
                        [self.tableView endUpdates];
                    }
                }];
            }
        }];
    }
    
    return NO;
}

@end
