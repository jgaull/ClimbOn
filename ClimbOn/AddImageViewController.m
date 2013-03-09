//
//  AddImageViewController.m
//  ClimbOn
//
//  Created by Grant Helton on 3/9/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AddImageViewController.h"

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

- (IBAction)onAddImageButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [actionSheet showInView:self.view];
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
    
    [self.selectedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving route" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
        }
    }];
    
    self.addImageButton.enabled = false;
}

@end