//
//  FirstAscentViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/23/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FirstAscentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) PFObject *route;
@property (nonatomic, strong) PFObject *post;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end
