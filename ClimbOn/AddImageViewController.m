//
//  AddImageViewController.m
//  ClimbOn
//
//  Created by Grant Helton on 3/9/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AddImageViewController.h"
#import "FirstAscentViewController.h"
#import "Constants.h"
#import "ClimbOnUtils.h"

@interface AddImageViewController ()

@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

@end

@implementation AddImageViewController

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
    
    //any additional setup
    self.progressBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    self.addImageButton = nil;
    self.progressBar = nil;
    self.addImageButton = nil;
    self.route = nil;
    self.post = nil;
    self.doneButton = nil;
    self.userImageView = nil;
}

#pragma mark - button listeners

- (IBAction)onAddImageButton:(id)sender {
    [self displayPhotoSourcePicker];
}

- (IBAction)onDoneButton:(id)sender {
    [self exitView];
}

#pragma mark - advancing the user flow
-(void)exitView {
	unsigned int climbingType = [[[self.route objectForKey:kKeyRouteRating] objectForKey:kKeyRatingClimbingType] intValue];
    if (climbingType == 0 && [self didSendRoute]) {
        [self performSegueWithIdentifier:@"rateRoute" sender:self];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [ClimbOnUtils savePostInBackground:self.post];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    FirstAscentViewController *nextViewController = (FirstAscentViewController *)segue.destinationViewController;
    nextViewController.route = self.route;
    nextViewController.post = self.post;
}

#pragma Mark - saving the post
- (void) uploadFile:(PFFile *)file {
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving photo" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
            self.doneButton.enabled = YES;
        } else {
            [self updatePostAndRouteWithMedia:file];
        }
    } progressBlock:^(int percentDone) {
        float percentage = percentDone;
        self.progressBar.progress = percentage / 100;
    }];
}

- (void) updatePostAndRouteWithMedia:(PFFile *)file {
    [self.post setObject:file forKey:kKeyPostPhotoFile];
    [self exitView];
}

#pragma mark - Actionsheet Methods

- (void)displayPhotoSourcePicker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == ButtonCancel) {
        NSLog(@"Cancel");
    }
    else {
        self.doneButton.enabled = NO;
        UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
        imagePickController.delegate = self;
        imagePickController.allowsEditing = YES;
        
        if (buttonIndex == ButtonTakePhoto) {
            imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (buttonIndex == ButtonPickPhoto) {
            imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:imagePickController animated:YES completion:nil];
    }
    
}

#pragma mark - Imagepicker Controller

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.progressBar.progress = 0.0f;
    self.progressBar.hidden = NO;
    
    NSURL *selectedUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//    [self.selectedImageView setImage:selectedVideo];
    
    // newly created photo
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UISaveVideoAtPathToSavedPhotosAlbum(selectedUrl.path, nil, nil, nil);
    }
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIGraphicsBeginImageContext(CGSizeMake(640, 640));
    [image drawInRect: CGRectMake(0, 0, 640, 640)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.userImageView.image = image;
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.50f);
    [self uploadFile:[PFFile fileWithName:@"photo.jpeg" data:imageData]];
}

@end
