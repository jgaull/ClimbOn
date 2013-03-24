//
//  AddImageViewController.m
//  ClimbOn
//
//  Created by Grant Helton on 3/9/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AddImageViewController.h"
#import "FirstAscentViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AddImageViewController ()

@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;

@property (strong, nonatomic) UIImagePickerController *imagePickController;
@property (strong, nonatomic) PFFile *selectedPhoto;
@property (strong, nonatomic) NSURL *selectedUrl;

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
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsReady:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    self.progressBar.hidden = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.imagePickController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    FirstAscentViewController *nextViewController = (FirstAscentViewController *)segue.destinationViewController;
    nextViewController.route = self.route;
    nextViewController.post = self.post;
}

- (IBAction)onAddImageButton:(id)sender {
    [self displayPhotoSourcePicker];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == ButtonSkip) {
        [self exitView];
    }
}

-(void)exitView {
    if (![self.route objectForKey:@"firstAscent"] && [self didSendRoute])
        [self performSegueWithIdentifier:@"rateRoute" sender:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraIsReady:(NSNotification *)notification
{
    NSLog(@"Camera is ready...");
    // Whatever
    //    [self.imagePickController startVideoCapture];
}

- (void) uploadFile:(PFFile *)file {
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving route" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
        } else {
            [self createMediaObjectWithFile:file];
        }
    } progressBlock:^(int percentDone) {
        float percentage = percentDone;
        self.progressBar.progress = percentage / 100;
        NSLog(@"%d", (percentDone));
    }];
}

- (void) createMediaObjectWithFile:(PFFile *)file {
    PFObject *media = [[PFObject alloc] initWithClassName:@"Media"];
    [media setObject:self.selectedPhoto forKey:@"file"];
    [media saveEventually:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"image saved successfully!");
            //do something
            [self updatePostAndRouteWithMedia:media];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went terribly wrong adding your image." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Bummer", nil];
            [alert show];
        }
    }];
}

- (void) updatePostAndRouteWithMedia:(PFObject *)media {
    [self.post setObject:media forKey:@"photo"];
    [self.post saveInBackground];
    
    // set route image
    if([self.route objectForKey:@"photo"] == nil)
    {
        [self.route setObject:media forKey:@"photo"];
        [self.route saveInBackground];
    }
    [self exitView];
}

-(void)dealloc {
    self.addImageButton = nil;
    self.selectedPhoto = nil;
    self.imagePickController = nil;
}

#pragma Mark Actionsheet Methods

- (void)displayPhotoSourcePicker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == ButtonCancel) {
        NSLog(@"Cancel");
    }
    else {
        if(self.imagePickController == nil)
            self.imagePickController = [[UIImagePickerController alloc] init];
        self.imagePickController.delegate = self;
        self.imagePickController.allowsEditing = YES;
        
        if (buttonIndex == ButtonTakePhoto) {
            self.imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (buttonIndex == ButtonPickPhoto) {
            self.imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:self.imagePickController animated:YES completion:nil];
    }
    
}

#pragma Mark Imagepicker Controller

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.progressBar.progress = 0.0f;
    self.progressBar.hidden = NO;
    
    self.selectedUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//    [self.selectedImageView setImage:selectedVideo];
    
    // newly created photo
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UISaveVideoAtPathToSavedPhotosAlbum(self.selectedUrl.path, nil, nil, nil);
    }
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 1.0f);
    
    self.selectedPhoto = [PFFile fileWithName:@"photo.jpeg0" data:imageData];
    
    if(self.selectedPhoto != nil)
        [self uploadFile:self.selectedPhoto];
    else if(self.selectedPhoto == nil) {
        if([self.route objectForKey:@"photo"] == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh" message:@"This route needs its first photo!" delegate:self cancelButtonTitle:@"I'll add one!" otherButtonTitles:@"Post Anyway...", nil];
            [alert show];
        } else {
            [self exitView];
        }
    }
}

@end
