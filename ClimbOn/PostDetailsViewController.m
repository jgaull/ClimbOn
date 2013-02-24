//
//  PostDetailsViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/21/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "CheckInViewController.h"

@interface PostDetailsViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (strong, nonatomic) IBOutlet UITextView *postTextField;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UITextField *commentField;
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
    
    // Configure the cell...
    self.title = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];
    self.postTextField.text = [self.postData objectForKey:@"userText"];
    [self.routeNameButton setTitle:[NSString stringWithFormat:@"%@, %@", [route objectForKey:@"name"], [rating objectForKey:@"name"]] forState:UIControlStateNormal];
    //cell.dateLabel.text = [self.postData objectForKey:@"createdAt"];
    
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Like"];
    [query whereKey:@"post" equalTo:self.postData];
    [query whereKey:@"originator" equalTo:[PFUser currentUser]];
    self.likeButton.enabled = NO;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self.likeButton setImage:[UIImage imageNamed:@"likebuttonliked.png"] forState:UIControlStateNormal];
            self.likeData = object;
        }
        else {
            [self.likeButton setImage:[UIImage imageNamed:@"likebutton.png"] forState:UIControlStateNormal];
        }
        
        self.likeButton.enabled = YES;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLikeButton:(id)sender {
    self.likeButton.enabled = NO;
    if (self.likeData) {
        [self.likeData deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.likeButton setImage:[UIImage imageNamed:@"likebutton.png"] forState:UIControlStateNormal];
                self.likeData = nil;
            }
            
            self.likeButton.enabled = YES;
        }];
    }
    else {
        PFObject *likeData = [[PFObject alloc] initWithClassName:@"Like"];
        [likeData setObject:[PFUser currentUser] forKey:@"originator"];
        [likeData setObject:self.postData forKey:@"post"];
        self.likeData = likeData;
        [likeData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.likeButton setImage:[UIImage imageNamed:@"likebuttonliked.png"] forState:UIControlStateNormal];
            }
            
            self.likeButton.enabled = YES;
        }];
    }
}

@end
