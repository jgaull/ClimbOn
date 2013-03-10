//
//  AddImageViewController.m
//  ClimbOn
//
//  Created by Grant Helton on 3/9/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AddImageViewController.h"
#import "FirstAscentViewController.h"

@interface AddImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *submitButton;

@property (strong, nonatomic) UIImagePickerController *imagePickController;
@property (strong, nonatomic) PFFile *selectedVideo;

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)onDoneButton:(id)sender {
    // save post image
    if(self.selectedVideo != nil)
        [self uploadFile:self.selectedVideo];
    else if(self.selectedVideo == nil) {
        if([self.route objectForKey:@"video"] == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh" message:@"This route needs its first photo!" delegate:self cancelButtonTitle:@"I'll add one!" otherButtonTitles:@"Post Anyway...", nil];
            [alert show];
        } else {
            [self exitView];
        }
    }
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

- (void) uploadFile:(PFFile *)file {
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving route" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
        } else {
            [self createMediaObjectWithFile:file];
        }
    }];
}

- (void) createMediaObjectWithFile:(PFFile *)file {
    PFObject *media = [[PFObject alloc] initWithClassName:@"Media"];
    [media setObject:self.selectedVideo forKey:@"file"];
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
    [self.post setObject:media forKey:@"video"];
    [self.post saveInBackground];
    
    // set route image
    if([self.route objectForKey:@"video"] == nil)
    {
        [self.route setObject:media forKey:@"video"];
        [self.route saveInBackground];
    }
    [self exitView];
}

-(void)dealloc {
    self.selectedImageView = nil;
    self.addImageButton = nil;
    self.submitButton = nil;
    self.selectedVideo = nil;
    self.imagePickController = nil;
}

- (void)cameraIsReady:(NSNotification *)notification
{
    NSLog(@"Camera is ready...");
    // Whatever
//    [self.imagePickController startVideoCapture];
}

#pragma Mark Actionsheet Methods

- (void)displayPhotoSourcePicker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Create New Video", @"Choose Video", nil];
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
        self.imagePickController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        
        if (buttonIndex == ButtonTakePhoto) {
            self.imagePickController.videoQuality = UIImagePickerControllerQualityType640x480;
            self.imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePickController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            self.imagePickController.showsCameraControls = YES;
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
    
    NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//    [self.selectedImageView setImage:selectedVideo];
    
    // newly created video
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, nil, nil, nil);
    }
    
//    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
//    [selectedImage drawInRect: CGRectMake(0, 0, 640, 960)];
//    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    self.selectedVideo = [PFFile fileWithName:@"video.m4v" contentsAtPath:videoUrl.path];
    self.submitButton.title = @"Upload & Save";
}

@end
