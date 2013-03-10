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

@property (strong, nonatomic) PFFile *selectedImage;

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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)onDoneButton:(id)sender {
    if (![self.route objectForKey:@"firstAscent"] && [self didSendRoute]) {
        [self performSegueWithIdentifier:@"rateRoute" sender:self];
    } else {
        // save post image
        [self uploadFile:self.selectedImage];
    }
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
    [media setObject:self.selectedImage forKey:@"file"];
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
    [self.post setObject:media forKey:@"media"];
    [self.post saveInBackground];
    
    // set route image
    if([self.route objectForKey:@"media"] == nil)
    {
        [self.route setObject:media forKey:@"media"];
        [self.route saveInBackground];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma Mark Actionsheet Methods

- (void)displayPhotoSourcePicker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    [actionSheet showInView:self.view];
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
    [self.selectedImageView setImage:selectedImage];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [selectedImage drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.selectedImage = [PFFile fileWithName:@"image" data:UIImageJPEGRepresentation(smallImage, 0.05f)];
}

@end
