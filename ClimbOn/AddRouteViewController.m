//
//  FirstViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AddRouteViewController.h"
#import <Parse/Parse.h>

@interface AddRouteViewController ()

@property (strong, nonatomic) IBOutlet UITextField *routeNameField;
@property (strong, nonatomic) IBOutlet UITextField *routeRatingField;
@property (strong, nonatomic) IBOutlet UIButton *addStartPicButton;
@property (strong, nonatomic) IBOutlet UIButton *addFinishPicButton;
@property (strong, nonatomic) IBOutlet UIImageView *startImage;
@property (strong, nonatomic) IBOutlet UIImageView *finishImage;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) int selectingImage;

@end

@implementation AddRouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Add Route";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark Touch event listeners

- (IBAction)onStartPicButton:(UIButton *)sender {
    self.selectingImage = kStart;
    [self displayPhotoSourcePicker];
}

- (IBAction)onFinishPicButton:(UIButton *)sender {
    self.selectingImage = kFinish;
    [self displayPhotoSourcePicker];
}


- (IBAction)onSaveButton:(UIButton *)sender {
    PFObject *newRoute = [PFObject objectWithClassName:@"Route"];
    
    [newRoute setObject:self.routeNameField.text forKey:@"name"];
    [newRoute setObject:self.routeRatingField.text forKey:@"rating"];
    [newRoute setObject:[PFUser currentUser] forKey:@"creator"];
    
    [newRoute saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Dismiss the NewPostViewController and show the BlogTableViewController
            self.routeRatingField.text = @"";
            self.routeNameField.text = @"";
            self.startImage.image = nil;
            self.finishImage.image = nil;
            self.addFinishPicButton.hidden = NO;
            self.addStartPicButton.hidden = NO;
        }
    }];
}

#pragma Mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

#pragma Mark Actionsheet Methods

- (void)displayPhotoSourcePicker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    [actionSheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
    //You can use isSourceTypeAvailable to check
    imagePickController.delegate = self;
    imagePickController.allowsEditing = NO;
    
    switch (buttonIndex) {
        case 0:
            imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickController.showsCameraControls = YES;
            break;
            
        case 1:
            imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            NSLog(@"Cancel");
            break;
    }
    
    [self presentViewController:imagePickController animated:YES completion:nil];
}

#pragma Mark Imagepicker Controller

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImageView *imageView = self.selectingImage == kStart ? self.startImage : self.finishImage;
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    imageView.image = selectedImage;
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
    }
    
    if (self.selectingImage == kStart) {
        self.addStartPicButton.hidden = YES;
    }
    else {
        self.addFinishPicButton.hidden = YES;
    }
}

@end
