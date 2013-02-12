//
//  CheckInViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/11/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CheckInViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) PFObject *route;

- (void)textViewDidChange:(UITextView *)textView;

@end
