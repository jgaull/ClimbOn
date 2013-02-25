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
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;

@property (strong, nonatomic) PFFile *selectedImage;

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
    
    if (self.postType == kPostTypeTopOut) {
        self.postTextView.text = [NSString stringWithFormat:@"I just topped out %@, %@", [self.route objectForKey:@"name"], [[self.route objectForKey:@"rating"] objectForKey:@"name"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDoneButton:(id)sender {
    if (![self.route objectForKey:@"firstAscent"] && self.postType == kPostTypeTopOut) {
        [self performSegueWithIdentifier:@"rateRoute" sender:self];
    }
    else {
        PFObject *post = [self getPostData];
        
        if ([self.route objectForKey:@"rating"] == nil) {
            
        }
        
        [self.route saveEventually];
        [post saveEventually];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (PFObject *)getPostData {
    PFObject *post = [[PFObject alloc] initWithClassName:@"Post"];
    [post setObject:self.postTextView.text forKey:@"userText"];
    [post setObject:[PFUser currentUser] forKey:@"creator"];
    [post setObject:self.route forKey:@"route"];
    [post setObject:[NSNumber numberWithInt:self.postType] forKey:@"type"];
    
    if (self.selectedImage) {
        [post setObject:self.selectedImage forKey:@"image"];
    }
    
    return post;
}

- (IBAction)onAddImageButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [actionSheet showInView:self.tabBarController.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    FirstAscentViewController *nextViewController = (FirstAscentViewController *)segue.destinationViewController;
    nextViewController.routeData = self.route;
    nextViewController.postData = [self getPostData];
}

#pragma Mark Text View Delegate methods.

- (void)textViewDidChange:(UITextView *)textView {
    
}

- (void)setRoute:(PFObject *)route {
    if (route != _route) {
        _route = route;
        self.title = [_route objectForKey:@"name"];
    }
}

 #pragma Mark Actionsheet Methods
 
 - (void)displayPhotoSourcePicker {
     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
     [actionSheet showInView:self.tabBarController.view];
 }
 
 - (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
     
     if (buttonIndex == 2) {
         NSLog(@"Cancel");
     }
     else {
         UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
         imagePickController.delegate = self;
         imagePickController.allowsEditing = NO;
         
         if (buttonIndex == 0) {
             imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickController.showsCameraControls = YES;
         }
         else if (buttonIndex == 1) {
             imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
         }
         
         [self presentViewController:imagePickController animated:YES completion:nil];
     }
     
 }
 
 #pragma Mark Imagepicker Controller
 
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
     [self dismissViewControllerAnimated:YES completion:nil];
 }
 
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
 
     [self dismissViewControllerAnimated:YES completion:nil];
     
     UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
     
     if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
         UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
     }
     
     UIGraphicsBeginImageContext(CGSizeMake(640, 960));
     [selectedImage drawInRect: CGRectMake(0, 0, 640, 960)];
     UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     self.selectedImage = [PFFile fileWithName:@"image" data:UIImageJPEGRepresentation(smallImage, 0.05f)];
     
     [self.selectedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving route" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
             [alert show];
         }
     }];
     
     self.addImageButton.enabled = false;
 }

@end
