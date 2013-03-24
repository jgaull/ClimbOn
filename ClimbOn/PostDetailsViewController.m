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
    
    PFUser *creator = [self.postData objectForKey:@"creator"];
    PFObject *route = [self.postData objectForKey:@"route"];
    PFObject *rating = [route objectForKey:@"rating"];
    PFObject *postPhoto = [self.postData objectForKey:@"photo"];
    //PFObject *routePhoto = [route objectForKey:@"photo"];
    
    // Configure the cell...
    self.postImage.file = nil;
    self.title = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
    [self.routeNameButton setTitle:[NSString stringWithFormat:@"%@, %@", [route objectForKey:@"name"], [rating objectForKey:@"name"]] forState:UIControlStateNormal];
    
    self.userProfileImage.file = [creator objectForKey:@"profilePicture"];
    [self.userProfileImage loadInBackground:^(UIImage *image, NSError *error) {
        [self.view setNeedsDisplay];
    }];
    
    [postPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.postImage.file = [object objectForKey:@"file"];
        [self.view setNeedsDisplay];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLikeButton:(id)sender {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewRoute"]) {
        RouteViewController *viewController = (RouteViewController *)segue.destinationViewController;
        viewController.routeData = [self.postData objectForKey:@"route"];
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
