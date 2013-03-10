//
//  CheckInViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/11/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

const int kPostTypeCheckIn = 0;
const int kPostTypeTopOut = 1;

@interface CheckInViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) PFObject *route;
@property (strong, nonatomic) PFObject *post;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;


@end
