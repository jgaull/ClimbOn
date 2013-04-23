//
//  CheckInViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/11/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "CheckInViewController.h"
#import "AddImageViewController.h"
#import "Constants.h"

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
    self.post = [[PFObject alloc] initWithClassName:kClassPost];
    [self.post setObject:[PFUser currentUser] forKey:kKeyPostCreator];
    [self.post setObject:self.route forKey:kKeyPostRoute];
    [self.post setObject:[NSNumber numberWithInt:[self.accomplishmentSelectorSegmentedControl selectedSegmentIndex]] forKey:kKeyPostType];
    
    if (![self.postTextView.text isEqualToString:@""]) {
        PFObject *comment = [[PFObject alloc] initWithClassName:kClassComment];
        [comment setObject:[PFUser currentUser] forKey:kKeyPostCreator];
        [comment setObject:self.postTextView.text forKey:@"commentText"];
        [self.post setObject:comment forKey:kKeyPostUserText];
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
