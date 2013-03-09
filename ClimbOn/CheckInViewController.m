//
//  CheckInViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/11/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "CheckInViewController.h"
#import "FirstAscentViewController.h"

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

- (PFObject *)getPostData {
    PFObject *post = [[PFObject alloc] initWithClassName:@"Post"];
    [post setObject:[PFUser currentUser] forKey:@"creator"];
    [post setObject:self.route forKey:@"route"];
    [post setObject:self.selectedTags forKey:@"tags"];
    
    return post;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    FirstAscentViewController *nextViewController = (FirstAscentViewController *)segue.destinationViewController;
    nextViewController.routeData = self.route;
    nextViewController.postData = [self getPostData];
}

#pragma Mark button listeners

- (IBAction)onHashtagButton:(UIButton *)sender {
    PFObject *selectedTag = [self.suggestedTags objectForKey:sender.titleLabel.text];
    if ([self.selectedTags containsObject:selectedTag]) {
        [self.selectedTags removeObject:selectedTag];
        sender.selected = NO;
    }
    else {
        [self.selectedTags addObject:selectedTag];
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
        else if (![self.route objectForKey:@"firstAscent"] && [self didSendRoute]) {
            [self performSegueWithIdentifier:@"rateRoute" sender:self];
        }
        else {
            PFObject *post = [self getPostData];
            [self.route saveEventually];
            
            if (![self.postTextView.text isEqualToString:@""]) {
                PFObject *comment = [[PFObject alloc] initWithClassName:@"Comment"];
                [comment setObject:[PFUser currentUser] forKey:@"creator"];
                [comment setObject:self.postTextView.text forKey:@"commentText"];
                
                [comment saveEventually:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        PFRelation *commentsRelation = [post relationforKey:@"comments"];
                        [commentsRelation addObject:comment];
                        [post saveEventually];
                    }
                }];
            }
            else {
                [post saveEventually];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma Mark Text View Delegate methods.

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.checkInButton.title = @"Done";
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.checkInButton.title = @"Check In";
}

- (void)textViewDidChange:(UITextView *)textView {
    
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
