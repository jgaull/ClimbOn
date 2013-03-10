//
//  AddImageViewController.h
//  ClimbOn
//
//  Created by Grant Helton on 3/9/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface AddImageViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) PFObject *route;
@property (nonatomic, strong) PFObject *post;
@property (nonatomic) BOOL didSendRoute;

enum ImageActionButtons:NSInteger{
    ButtonTakePhoto,
    ButtonPickPhoto,
    ButtonCancel
};

enum FirstImageWarningButtons:NSInteger{
    ButtonGoBack,
    ButtonSkip
};

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
