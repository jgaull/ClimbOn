//
//  FirstViewController.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

static const int kStart = 0;
static const int kFinish = 1;

@interface AddRouteViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager;

@end
