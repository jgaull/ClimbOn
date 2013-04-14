//
//  CheckInViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/11/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "CheckInViewController.h"
#import "AddImageViewController.h"

@interface CheckInViewController ()

@property (strong, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *checkInButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *accomplishmentSelectorSegmentedControl;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    AddImageViewController *nextViewController = (AddImageViewController *)segue.destinationViewController;
    
    NSInteger accomplishment = self.accomplishmentSelectorSegmentedControl.selectedSegmentIndex;
    BOOL didSendRoute = accomplishment == Flash || accomplishment == Send;
    
    nextViewController.route = self.route;
    nextViewController.post = self.post;
    nextViewController.didSendRoute = didSendRoute;
}

-(void)dealloc {
    self.postTextView = nil;
    self.checkInButton = nil;
    self.route = nil;
    self.post = nil;
}

#pragma Mark button listeners

- (IBAction)onDoneButton:(id)sender {
    [self onDone];
}

#pragma Mark Some Helper methods

- (void)onDone {
    self.post = [[PFObject alloc] initWithClassName:@"Post"];
    [self.post setObject:[PFUser currentUser] forKey:@"creator"];
    [self.post setObject:self.route forKey:@"route"];
    [self.post setObject:[NSNumber numberWithInt:[self.accomplishmentSelectorSegmentedControl selectedSegmentIndex]] forKey:@"type"];
    
    if (![self.postTextView.text isEqualToString:@""]) {
        PFObject *comment = [[PFObject alloc] initWithClassName:@"Comment"];
        [comment setObject:[PFUser currentUser] forKey:@"creator"];
        [comment setObject:self.postTextView.text forKey:@"commentText"];
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            if (!error) {
                PFRelation *commentsRelation = [self.post relationforKey:@"comments"];
                [commentsRelation addObject:comment];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went terribly wrong." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Bummer", nil];
                [alert show];
            }
        }];
    }
    
    [self performSegueWithIdentifier:@"addImage" sender:self];
}

#pragma Mark Text View Delegate methods.

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.checkInButton.title = @"Done";
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.checkInButton.title = @"Check In";
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self onDone];
        return NO;
    }
    
    return YES;
}

- (void)setRoute:(PFObject *)route {
    if (route != _route) {
        _route = route;
        self.title = [_route objectForKey:@"name"];
    }
}

@end
