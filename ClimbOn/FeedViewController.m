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
#import "CheckInCommentCell.h"
#import "LikeCell.h"
#import "PostImageCell.h"
#import "Constants.h"
#import "Cache.h"
#import "ClimbOnUtils.h"
#import "TTTTimeIntervalFormatter.h"

#import <MediaPlayer/MediaPlayer.h>

static const int kStaticHeadersCount = 2;
static const int kStaticFootersCount = 0;

static const int kHeaderCellIndex = 0;
static const int kLikesCellIndex = 1;

NSString *const HeadingCellIdentifier = @"headingCell";
NSString *const ImageCellIdentifier = @"imageCell";
NSString *const CommentCellIdentifier = @"commentCell";
NSString *const LikesCellIdentifier = @"likesCell";
NSString *const LoadingCellIdentifier = @"loadingCell";

@interface FeedViewController ()

@property (nonatomic, strong) NSMutableDictionary *outstandingPostInfoQueries;

@property (nonatomic, strong) NSArray *accomplishmentTypes;

@property (nonatomic) NSInteger postType;

@property (nonatomic) int remainingQueries;
@property (nonatomic) NSInteger numObjectsBeforeLoad;
//@property (nonatomic) BOOL isPlayingMovie;

@end

@implementation FeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.paginationEnabled = YES;
        self.objectsPerPage = 15;
        self.pullToRefreshEnabled = NO;
        self.loadingViewEnabled = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.accomplishmentTypes = [[NSArray alloc] initWithObjects:@"Sended, +5 points", @"Flashed, +10 points", @"Worked, +1 point", @"Lapped", nil];
    
    self.outstandingPostInfoQueries = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPostDidSave:) name:kNotificationPostDidSave object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    self.query = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPostDidSave object:nil];
}

#pragma mark - Button Listeners

- (IBAction)onLikeButton:(UIButton *)sender {
    
    int section = sender.tag;
    PFObject *post = [self.objects objectAtIndex:section];
    PFUser *postCreator = [post objectForKey:kKeyPostCreator];
    BOOL hasLiked = [[Cache sharedCache] getHasUserLikedPost:post];
    BOOL isLiking = !hasLiked;

    //Create a query for any existing likes.
    PFQuery *previousLikesQuery = [[PFQuery alloc] initWithClassName:kClassEvent];
    [previousLikesQuery whereKey:kKeyEventFromUser equalTo:[PFUser currentUser]];
    [previousLikesQuery whereKey:kKeyPostType equalTo:@"like"];
    [previousLikesQuery whereKey:kKeyEventPost equalTo:post];
    
    @synchronized(self) {
        [previousLikesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                //delete any existing likes from the database.
                @synchronized(self) {
                    
                    for (PFObject *previousLike in objects) {
                        [previousLike deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [[Cache sharedCache] unlikePost:post];
                            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLikesCellIndex inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
                        }];
                    }
                }
                
                //Create the like event
                if (isLiking) {
                    PFObject *likeEvent = [[PFObject alloc] initWithClassName:kClassEvent];
                    [likeEvent setObject:@"like" forKey:kKeyPostType];
                    [likeEvent setObject:[PFUser currentUser] forKey:kKeyEventFromUser];
                    [likeEvent setObject:postCreator forKey:kKeyEventToUser];
                    [likeEvent setObject:post forKey:kKeyEventPost];
                    [likeEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            //update the likers lookup
                            [[Cache sharedCache] likePost:post];
                            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLikesCellIndex inSection:section]] withRowAnimation:UITableViewRowAnimationNone];

							if([postCreator.objectId isEqualToString:[PFUser currentUser].objectId] == NO)
							{
								PFQuery *userQuery = [PFUser query];
								[userQuery whereKey:@"objectId" equalTo:postCreator.objectId];

								PFQuery *pushQuery = [PFInstallation query];
								[pushQuery whereKey:@"owner" matchesQuery:userQuery];

								PFPush *push = [[PFPush alloc] init];
								PFObject *route = [post objectForKey:@"route"];
								NSString *message = [NSString stringWithFormat:@"%@ just hearted your checkin at %@.", [ClimbOnUtils firstNameLastInitialWithUser:[PFUser currentUser]], [route objectForKey:@"name"]];

								[push setQuery:pushQuery]; // Set our Installation query
								[push setMessage:message];
								[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
									if(error)
										NSLog(@"error:%@",error);
								}];
							}
                        }
                    }];
                }
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.objects.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.objects.count) {
        NSInteger cellsForImages = [self cellsForImagesInSection:section];
        PFObject *userText = [self getCommentsForPost:[self.objects objectAtIndex:section]];
        NSInteger cellsForComments = userText != nil; //if this is not nil then there is 1 comment.
        
        return kStaticHeadersCount + cellsForImages + cellsForComments + kStaticFootersCount;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)postData {
    
    NSString *cellIdentifier = [self getCellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (indexPath.section < self.objects.count) {
        PFObject *routeData = [postData objectForKey:kKeyPostRoute];
        PFUser *creator = [postData objectForKey:kKeyPostCreator];
        
        NSDictionary *additionalPostInfo = [[Cache sharedCache] infoForPost:postData];
        if (!additionalPostInfo) {
            if (![self.outstandingPostInfoQueries objectForKey:[NSNumber numberWithInt:indexPath.section]]) {
                PFQuery *eventsForPostQuery = [[PFQuery alloc] initWithClassName:kClassEvent];
                [eventsForPostQuery whereKey:kKeyEventPost equalTo:postData];
                [self.outstandingPostInfoQueries setObject:eventsForPostQuery forKey:[NSNumber numberWithInt:indexPath.section]];
                [eventsForPostQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        if (!error) {
                            [self.outstandingPostInfoQueries removeObjectForKey:[NSNumber numberWithInt:indexPath.section]];
                            NSMutableArray *likers = [[NSMutableArray alloc] init];
                            
                            for (PFObject *event in objects) {
                                NSString *eventType = [event objectForKey:kKeyPostType];
                                
                                if ([eventType isEqualToString:@"like"]) {
                                    PFUser *fromUser = [event objectForKey:kKeyEventFromUser];
                                    [likers addObject:fromUser];
                                }
                            }
                            
                            [[Cache sharedCache] setInfoForPost:postData likers:likers];
                            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLikesCellIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                }];
            }
        }
        
        if ([cell isKindOfClass:[CheckInHeadingCell class]]) {
            CheckInHeadingCell *checkinHeadingCell = (CheckInHeadingCell *)cell;
            
            PFObject *rating = [routeData objectForKey:kKeyRouteRating];
            NSInteger *accomplishmentType = [[postData objectForKey:kKeyPostType] integerValue];
            TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
            
            checkinHeadingCell.userProfilePic.file = [creator objectForKey:kKeyUserProfilePicture];
            [checkinHeadingCell.userProfilePic loadInBackground];
            checkinHeadingCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:kKeyUserFirstName], [creator objectForKey:kKeyUserLastName]];
            checkinHeadingCell.routeNameLabel.text = [NSString stringWithFormat:@"%@, %@", [routeData objectForKey:kKeyRouteName], [rating objectForKey:kKeyRatingName]];
            checkinHeadingCell.accomplishmentLabel.text = [NSString stringWithFormat:@"%@", [self.accomplishmentTypes objectAtIndex:accomplishmentType]];
            checkinHeadingCell.dateLabel.text = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:postData.createdAt];
        }
        else if ([cell isKindOfClass:[PostImageCell class]]) {
            PostImageCell *postImageCell = (PostImageCell *)cell;
            postImageCell.postImageView.file = nil;
            PFFile *image = [postData objectForKey:kKeyPostPhotoFile];
            postImageCell.postImageView.file = image;
            [postImageCell.postImageView loadInBackground];
        }
        else if ([cell isKindOfClass:[CheckInCommentCell class]]) {
            CheckInCommentCell *checkinCommentCell = (CheckInCommentCell *)cell;
            cell = checkinCommentCell;
            
            PFObject *comment = [self getCommentForIndexPath:indexPath];
            PFUser *creator = [comment objectForKey:kKeyCommentCreator];
            [creator fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                checkinCommentCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:kKeyUserFirstName], [creator objectForKey:kKeyUserLastName]];
            }];
            
            checkinCommentCell.commentTextView.text = [comment objectForKey:kKeyCommentCommentText];
        }
        else if ([cell isKindOfClass:[LikeCell class]]) {
            LikeCell *likeCell = (LikeCell *)cell;
            likeCell.likeButton.tag = indexPath.section;
            likeCell.likesLabel.text = [NSString stringWithFormat:@"%d", [[Cache sharedCache] getLikersForPost:postData].count];
            
            BOOL hasLiked = [[Cache sharedCache] getHasUserLikedPost:postData];
            NSString *buttonImage = hasLiked ? @"likebuttonliked.png" : @"likebutton.png";
            [likeCell.likeButton setImage:[UIImage imageNamed:buttonImage] forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
}

// Override if you need to change the ordering of objects in the table.
- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
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
        size = [[comment objectForKey:kKeyCommentCommentText] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 21 + 16;
    }
    else if ([LoadingCellIdentifier isEqualToString:cellIdentifier]) {
        return 48;
    }
    else {
        NSLog(@"%@ does not have code to calculate its height.", cellIdentifier);
    }
    
    return 0;
}

- (NSString *)getCellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section < self.objects.count) {
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
    
    return LoadingCellIdentifier;
}

- (NSInteger)cellsForImagesInSection:(NSInteger)section {
    PFObject *post = [self.objects objectAtIndex:section];
    PFFile *photo = [post objectForKey:kKeyPostPhotoFile];
    return photo != nil;
}

- (PFObject *)getCommentsForPost:(PFObject *)post {
    return [post objectForKey:kKeyPostUserText];
}

- (PFObject *)getCommentForIndexPath:(NSIndexPath *)indexPath {
    PFObject *post = [self.objects objectAtIndex:indexPath.section];
    return [post objectForKey:kKeyPostUserText];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostDetails"] || [segue.identifier isEqualToString:@"alsoShowPostDetails"]) {
        PostDetailsViewController *postDetails = (PostDetailsViewController *)segue.destinationViewController;
        postDetails.postData = [self.objects objectAtIndex:self.tableView.indexPathForSelectedRow.section];
    }
    
    [super prepareForSegue:segue sender:sender];
}

#pragma mark - Handling loading the data.

- (PFQuery *)queryForTable {
	if(!self.query)
		self.query = [PFQuery queryWithClassName:kClassPost];
    
    [self.query includeKey:kKeyPostCreator];
    [self.query includeKey:kKeyPostRoute];
    [self.query includeKey:[NSString stringWithFormat:@"%@.%@", kKeyPostRoute, kKeyRouteRating]];
    [self.query includeKey:kKeyPostUserText];
    [self.query orderByDescending:kKeyCreatedAt];
    
    return self.query;
}

#pragma mark - Refresh control functions

- (void)onRefresh:(UIRefreshControl *)sender {
    [self loadObjects];
}

- (void)objectsWillLoad {
    self.numObjectsBeforeLoad = self.objects.count;
    [super objectsWillLoad];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.refreshControl endRefreshing];
}

- (void)onPostDidSave:(NSNotification *)note {
    [self loadObjects];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.bounds.size.height && !self.isLoading && self.numObjectsBeforeLoad != self.objects.count) {
        [self loadNextPage];
        NSLog(@"Loading");
    }
}

- (BOOL)hasLoadedNewData {
    return self.objects.count != self.numObjectsBeforeLoad;
}

@end
