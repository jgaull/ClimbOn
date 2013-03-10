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

@property (strong, nonatomic) NSMutableArray *selectedTags;
@property (strong, nonatomic) NSDictionary *suggestedTags;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *checkInButton;

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
    
    self.selectedTags = [[NSMutableArray alloc] init];
    self.checkInButton.enabled = NO;
    
    PFQuery *topOutQuery = [[PFQuery alloc] initWithClassName:@"Tag"];
    [topOutQuery whereKey:@"type" equalTo:@"topOut"];
    PFQuery *suggestedQuery = [[PFQuery alloc] initWithClassName:@"Tag"];
    [suggestedQuery whereKey:@"type" equalTo:@"suggested"];
    PFQuery *query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:topOutQuery, suggestedQuery, nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableDictionary *suggestedTags = [[NSMutableDictionary alloc] init];
            for (PFObject *tag in objects) {
                [suggestedTags setObject:tag forKey:[tag objectForKey:@"name"]];
            }
            
            self.suggestedTags = [[NSDictionary alloc] initWithDictionary:suggestedTags];
        }
        else {
            NSLog(@"Error fetching tags: %@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    AddImageViewController *nextViewController = (AddImageViewController *)segue.destinationViewController;
    nextViewController.route = self.route;
    nextViewController.post = self.post;
    nextViewController.didSendRoute = [self didSendRoute];
}

-(void)dealloc {
    self.postTextView = nil;
    self.selectedTags = nil;
    self.suggestedTags = nil;
    self.checkInButton = nil;
    self.route = nil;
    self.post = nil;
}

#pragma Mark button listeners

- (IBAction)onHashtagButton:(UIButton *)sender {
    PFObject *selectedTag = [self.suggestedTags objectForKey:sender.titleLabel.text];
    if ([self.selectedTags containsObject:selectedTag]) {
        [self.selectedTags removeObject:selectedTag];
        self.checkInButton.enabled = [self shouldEnableCheckIn];
        sender.selected = NO;
    }
    else {
        [self.selectedTags addObject:selectedTag];
        self.checkInButton.enabled = YES;
        sender.selected = YES;
    }
}

- (IBAction)onDoneButton:(id)sender {
    if (self.postTextView.isFirstResponder) {
        [self.postTextView resignFirstResponder];
    }
    else {
        if (self.selectedTags.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Tags" message:@"Please select at least one tag." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alert show];
        }
        else {
            self.post = [[PFObject alloc] initWithClassName:@"Post"];
            [self.post setObject:[PFUser currentUser] forKey:@"creator"];
            [self.post setObject:self.route forKey:@"route"];
            [self.post setObject:self.selectedTags forKey:@"tags"];
            
//            [self.route saveEventually];
            
            if (![self.postTextView.text isEqualToString:@""]) {
                PFObject *comment = [[PFObject alloc] initWithClassName:@"Comment"];
                [comment setObject:[PFUser currentUser] forKey:@"creator"];
                [comment setObject:self.postTextView.text forKey:@"commentText"];
                
                [comment saveEventually:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        PFRelation *commentsRelation = [self.post relationforKey:@"comments"];
                        [commentsRelation addObject:comment];
                        [self.post saveEventually];
                        [self performSegueWithIdentifier:@"addImage" sender:sender];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went terribly wrong." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Bummer", nil];
                        [alert show];
                    }
                }];
            }
            else {
                [self.post saveEventually];
                [self performSegueWithIdentifier:@"addImage" sender:sender];
            }
            
        }
    }
}

- (BOOL)didSendRoute {
    for (PFObject *tag in self.selectedTags) {
        NSString *type = [tag objectForKey:@"type"];
        if ([type isEqualToString:@"topOut"]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldEnableCheckIn {
    if(self.selectedTags.count == 0) //should maybe check that they entered text
        return NO;
    else
        return YES;
}

#pragma Mark Text View Delegate methods.

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.checkInButton.title = @"Done";
    self.checkInButton.enabled = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.checkInButton.title = @"Check In";
    self.checkInButton.enabled = [self shouldEnableCheckIn];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.postTextView resignFirstResponder];
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

- (IBAction)checkInButton:(id)sender {
}
@end
