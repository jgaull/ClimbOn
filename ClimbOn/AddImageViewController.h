//
//  AddImageViewController.h
//  ClimbOn
//
//  Created by Grant Helton on 3/9/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddImageViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) PFObject *route;
@property (nonatomic, strong) PFObject *post;
@property (nonatomic) BOOL didSendRoute;

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
