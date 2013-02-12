//
//  CheckInViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/11/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "CheckInViewController.h"

@interface CheckInViewController ()

@property (strong, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) IBOutlet UIButton *checkInButton;

@end

@implementation CheckInViewController

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
    
    [self.postTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCheckInButton:(id)sender {
    PFObject *post = [[PFObject alloc] initWithClassName:@"Post"];
    [post setObject:self.postTextView.text forKey:@"userText"];
    [post setObject:[PFUser currentUser] forKey:@"creator"];
    [post setObject:self.route forKey:@"route"];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Dismiss the NewPostViewController and show the BlogTableViewController
            
            [self.checkInButton setTitle:@"CHECKED IN" forState:UIControlStateNormal];
            self.checkInButton.enabled = NO;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving route" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
        }
    }];
}

- (IBAction)onDoneButton:(id)sender {
    [self.postTextView resignFirstResponder];
}

#pragma Mark Text View Delegate methods.

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"Change");
}

- (void)setRoute:(PFObject *)route {
    if (route != _route) {
        _route = route;
        self.title = [_route objectForKey:@"name"];
    }
}

@end
