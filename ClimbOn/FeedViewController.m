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

#import <MediaPlayer/MediaPlayer.h>

static const int kStaticHeadersCount = 2;
static const int kStaticFootersCount = 0;

static const int kHeaderCellIndex = 0;
static const int kLikesCellIndex = 1;

NSString *const HeadingCellIdentifier = @"headingCell";
NSString *const ImageCellIdentifier = @"imageCell";
NSString *const CommentCellIdentifier = @"commentCell";
NSString *const LikesCellIdentifier = @"likesCell";

@interface FeedViewController ()

@property (nonatomic, strong) NSMutableArray *postsList;
@property (nonatomic, strong) NSMutableDictionary *outstandingPostInfoQueries;
@property (nonatomic, strong) NSMutableDictionary *additionalPostInfoLookup;

@property (nonatomic, strong) NSMutableDictionary *pfImageFileLookup;

@property (nonatomic, strong) NSArray *accomplishmentTypes;
@property (nonatomic, strong) NSArray *pointValues;

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
    
    self.accomplishmentTypes = [[NSArray alloc] initWithObjects:@"Sended", @"Flashed", @"Worked", @"Lapped", nil];
    self.pointValues = [[NSArray alloc] initWithObjects:@"1 point", @"10 points", @"", @"", nil];
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
}

-(void)dealloc {
    self.postsList = nil;
    self.postsList = nil;
    self.pfImageFileLookup = nil;
    self.query = nil;
}

/*- (BOOL)shouldAutorotate {
    return self.isPlayingMovie;
}*/

#pragma mark - Button Listeners

/*- (IBAction)onMoreCommentsButton:(UIButton *)sender {
    NSInteger section = sender.tag;
    
    PFObject *post = [self.postsList objectAtIndex:section];
    PFObject *userText = [post objectForKey:@"userText"];
    
    PFRelation *relation = [post objectForKey:@"comments"];
    PFQuery *query = relation.query;
    [query orderByAscending:@"createdAt"];
    query.limit = 50;
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
}*/

- (IBAction)onLikeButton:(UIButton *)sender {
    
    int section = sender.tag;
    PFObject *post = [self.postsList objectAtIndex:section];
    PFUser *postCreator = [post objectForKey:@"creator"];
    NSMutableArray *likers = [self getLikersForPost:post];
    BOOL hasLiked = [self getHasUserLikedPost:post];
    BOOL isLiking = !hasLiked;

    //Create a query for any existing likes.
    PFQuery *previousLikesQuery = [[PFQuery alloc] initWithClassName:@"Event"];
    [previousLikesQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [previousLikesQuery whereKey:@"type" equalTo:@"like"];
    [previousLikesQuery whereKey:@"post" equalTo:post];
    
    @synchronized(self) {
        [previousLikesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                //delete any existing likes from the database.
                @synchronized(self) {
                    for (PFObject *previousLike in objects) {
                        [previousLike deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [likers removeObject:[PFUser currentUser]];
                            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLikesCellIndex inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
                        }];
                    }
                }
                
                //Create the like event
                if (isLiking) {
                    PFObject *likeEvent = [[PFObject alloc] initWithClassName:@"Event"];
                    [likeEvent setObject:@"like" forKey:@"type"];
                    [likeEvent setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [likeEvent setObject:postCreator forKey:@"creator"];
                    [likeEvent setObject:post forKey:@"post"];
                    [likeEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            
                            //update the likers lookup
                            [likers addObject:[PFUser currentUser]];
                            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLikesCellIndex inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }];
                }
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
    PFObject *userText = [self getCommentsForPost:[self.postsList objectAtIndex:section]];
    NSInteger cellsForComments = userText != nil; //if this is not nil then there is 1 comment.
    
    return kStaticHeadersCount + cellsForImages + cellsForComments + kStaticFootersCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *postData = [self.postsList objectAtIndex:indexPath.section];
    PFObject *routeData = [postData objectForKey:@"route"];
    PFUser *creator = [postData objectForKey:@"creator"];
    
    NSDictionary *additionalPostInfo = [self.additionalPostInfoLookup objectForKey:postData.objectId];
    if (!additionalPostInfo) {
        if (![self.outstandingPostInfoQueries objectForKey:[NSNumber numberWithInt:indexPath.section]]) {
            PFQuery *eventsForPostQuery = [[PFQuery alloc] initWithClassName:@"Event"];
            [eventsForPostQuery whereKey:@"post" equalTo:postData];
            [self.outstandingPostInfoQueries setObject:eventsForPostQuery forKey:[NSNumber numberWithInt:indexPath.section]];
            [eventsForPostQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                @synchronized(self) {
                    if (!error) {
                        [self.outstandingPostInfoQueries removeObjectForKey:[NSNumber numberWithInt:indexPath.section]];
                        NSMutableDictionary *additionalPostInfo = [[NSMutableDictionary alloc] init];
                        NSMutableArray *likers = [[NSMutableArray alloc] init];
                        
                        for (PFObject *event in objects) {
                            NSString *eventType = [event objectForKey:@"type"];
                            
                            if ([eventType isEqualToString:@"like"]) {
                                PFUser *fromUser = [event objectForKey:@"fromUser"];
                                [likers addObject:fromUser];
                            }
                        }
                        
                        [additionalPostInfo setObject:likers forKey:@"likers"];
                        [self.additionalPostInfoLookup setObject:additionalPostInfo forKey:postData.objectId];
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLikesCellIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }];
        }
    }
    
    NSString *cellIdentifier = [self getCellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([cell isKindOfClass:[CheckInHeadingCell class]]) {
        CheckInHeadingCell *checkinHeadingCell = (CheckInHeadingCell *)cell;
        
        PFObject *rating = [routeData objectForKey:@"rating"];
        NSInteger *accomplishmentType = [[postData objectForKey:@"type"] integerValue];
        
        checkinHeadingCell.userProfilePic.file = [creator objectForKey:@"profilePicture"];
        [checkinHeadingCell.userProfilePic loadInBackground];
        checkinHeadingCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
        checkinHeadingCell.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [routeData objectForKey:@"name"], [rating objectForKey:@"name"]];
        checkinHeadingCell.accomplishmentLabel.text = [NSString stringWithFormat:@"%@, %@", [self.accomplishmentTypes objectAtIndex:accomplishmentType], [self.pointValues objectAtIndex:accomplishmentType]];
    }
    else if ([cell isKindOfClass:[CheckinHashtagCell class]]) {
        CheckinHashtagCell *checkinHashtagCell = (CheckinHashtagCell *)cell;
        checkinHashtagCell.hashtagTextView.text = [self getTagListStringFromPost:postData];
    }
    else if ([cell isKindOfClass:[PostImageCell class]]) {
        PostImageCell *postImageCell = (PostImageCell *)cell;
        postImageCell.postImageView.file = nil;
        PFFile *image = [self.pfImageFileLookup objectForKey:postData.objectId];
        if (!image) {
            PFObject *media = [postData objectForKey:@"photo"];
            PFFile *imageFile = [media objectForKey:@"file"];
            postImageCell.postImageView.file = imageFile;
            [self.pfImageFileLookup setObject:imageFile forKey:postData.objectId];
            [postImageCell.postImageView loadInBackground];
        }
        else {
            postImageCell.postImageView.file = image;
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
        likeCell.likesLabel.text = [NSString stringWithFormat:@"%d", [self getLikersForPost:postData].count];
        
        BOOL hasLiked = [self getHasUserLikedPost:postData];
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
    
    NSString *cellIdentifier = [self getCellIdentifierForIndexPath:indexPath];
    
    if ([HeadingCellIdentifier isEqualToString:cellIdentifier]) {
        return 90;
    }
    else if ([LikesCellIdentifier isEqualToString:cellIdentifier]) {
        return 50;
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
    
    if (indexPath.row == kHeaderCellIndex) {
        return HeadingCellIdentifier;
    }
    else if (indexPath.row == kLikesCellIndex) {
        return LikesCellIdentifier;
    }
    else if (indexPath.row == kStaticHeadersCount && cellsForImages >= 1) {
        return ImageCellIdentifier;
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

- (PFObject *)getCommentsForPost:(PFObject *)post {
    return [post objectForKey:@"userText"];
}

- (PFObject *)getCommentForIndexPath:(NSIndexPath *)indexPath {
    PFObject *post = [self.postsList objectAtIndex:indexPath.section];
    return [post objectForKey:@"userText"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostDetails"] || [segue.identifier isEqualToString:@"alsoShowPostDetails"]) {
        PostDetailsViewController *postDetails = (PostDetailsViewController *)segue.destinationViewController;
        postDetails.postData = [self.postsList objectAtIndex:self.tableView.indexPathForSelectedRow.section];
    }
    
    [super prepareForSegue:segue sender:sender];
}

#pragma mark - Handling loading the data.

- (void)refresh {
    @synchronized(self) {
        self.additionalPostInfoLookup = [[NSMutableDictionary alloc] init];
        self.outstandingPostInfoQueries = [[NSMutableDictionary alloc] init];
        
        if (self.query == nil) {
            self.query = [PFQuery queryWithClassName:@"Post"];
            //[self.query whereKey:@"creator" containedIn:[[PFUser currentUser] objectForKey:@"following"]];
        }
        
        [self.query includeKey:@"creator"];
        [self.query includeKey:@"route"];
        [self.query includeKey:@"route.rating"];
        [self.query includeKey:@"route.media"];
        [self.query includeKey:@"tags"];
        [self.query includeKey:@"video"];
        [self.query includeKey:@"photo"];
        [self.query includeKey:@"userText"];
        [self.query orderByDescending:@"createdAt"];
        self.query.limit = 15;
        [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.postsList = [[NSMutableArray alloc] initWithArray:objects];
                [self.tableView reloadData];
            }
            else {
                NSLog(@"Dag, an error");
            }
            
            [self.refreshControl endRefreshing];
        }];
    }
}

#pragma mark - Text Field Delegate Methods

/*- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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
                        
                        PFObject *userText = [self getCommentsForPost:postData];
                        
                        [self.tableView beginUpdates];
                        [comments addObject:comment];
                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count + kStaticHeadersCount inSection:section]] withRowAnimation:UITableViewRowAnimationTop];
                        [self.tableView endUpdates];
                    }
                }];
            }
        }];
    }
    
    return NO;
}*/

#pragma mark - Cache helper methods

- (NSMutableArray *)getLikersForPost:(PFObject *)post {
    NSMutableDictionary *additionalData = [self getAdditionalInfoForPost:post];
    return [additionalData objectForKey:@"likers"];
}

- (NSMutableDictionary *)getAdditionalInfoForPost:(PFObject *)post {
    return [self.additionalPostInfoLookup objectForKey:post.objectId];
}

- (BOOL)getHasUserLikedPost:(PFObject *)post {
    NSMutableArray *likers = [self getLikersForPost:post];
    for (PFUser *liker in likers) {
        if ([[PFUser currentUser].objectId isEqualToString:liker.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

@end
