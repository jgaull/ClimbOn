//
//  PostDetailsViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/21/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "CheckInViewController.h"
#import "RouteViewController.h"
#import "Constants.h"
#import "PublicProfileViewController.h"

@interface PostDetailsViewController ()

@property (strong, nonatomic) IBOutlet PFImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet PFImageView *postImage;
@property (strong, nonatomic) IBOutlet UIButton *routeNameButton;

@property (strong, nonatomic) PFObject *likeData;

@end

@implementation PostDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    PFUser *creator = [self.postData objectForKey:kKeyPostCreator];
    PFObject *route = [self.postData objectForKey:kKeyPostRoute];
    PFObject *rating = [route objectForKey:kKeyRouteRating];
    PFFile *postPhoto = [self.postData objectForKey:kKeyPostPhotoFile];
    //PFObject *routePhoto = [route objectForKey:kKeyPostPhoto];
    
    // Configure the cell...
    self.postImage.file = nil;
    self.title = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:kKeyUserFirstName], [creator objectForKey:kKeyUserLastName]];
    [self.routeNameButton setTitle:[NSString stringWithFormat:@"%@, %@", [route objectForKey:kKeyRouteName], [rating objectForKey:kKeyRatingName]] forState:UIControlStateNormal];
    
    self.userProfileImage.file = [creator objectForKey:kKeyUserProfilePicture];
    [self.userProfileImage loadInBackground:^(UIImage *image, NSError *error) {
        [self.view setNeedsDisplay];
    }];
    
    self.postImage.file = postPhoto;
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLikeButton:(id)sender {
    
}
- (IBAction)onProfileTap:(id)sender {
	PFUser *currentUser = [PFUser currentUser];
    PFUser *creator = [self.postData objectForKey:kKeyPostCreator];
	if (creator == currentUser) {
		[self performSegueWithIdentifier:kSeguePrivateProfile sender:sender];
	} else {
		[self performSegueWithIdentifier:kSeguePublicProfile sender:sender];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueRoute]) {
        RouteViewController *viewController = (RouteViewController *)segue.destinationViewController;
        viewController.routeData = [self.postData objectForKey:kKeyPostRoute];
    } else if ([segue.identifier isEqualToString:kSeguePublicProfile]) {
		PublicProfileViewController *viewController = (PublicProfileViewController *)segue.destinationViewController;
		viewController.user = [self.postData objectForKey:kKeyPostCreator];
	}
}

-(void)dealloc {
    self.userProfileImage = nil;
    self.routeNameButton = nil;
    self.postImage = nil;
    self.likeData = nil;
    self.postData = nil;
}

@end
