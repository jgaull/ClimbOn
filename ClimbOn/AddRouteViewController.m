//
//  FirstViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AddRouteViewController.h"
#import "CheckInViewController.h"
#import <Parse/Parse.h>

@interface AddRouteViewController ()

@property (strong, nonatomic) IBOutlet UITextField *routeNameField;
@property (strong, nonatomic) IBOutlet UITextField *routeRatingField;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) PFObject *route;

@property (nonatomic) int selectingImage;

@end

@implementation AddRouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.routeNameField = nil;
    self.routeRatingField = nil;
    self.mapView = nil;
    self.locationManager = nil;
}

#pragma Mark Touch event listeners

- (IBAction)onSaveButton:(UIButton *)sender {
    
    UIAlertView *alert;
    if ([self.routeNameField.text isEqualToString:@""]) {
        alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please give the route a name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else if ([self.routeRatingField.text isEqualToString:@""]) {
        alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please give the route a rating." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        PFObject *route = self.route;
        
        if (!route) {
            route = [PFObject objectWithClassName:@"Route"];
        }
        
        [route setObject:self.routeNameField.text forKey:@"name"];
        [route setObject:self.routeRatingField.text forKey:@"rating"];
        [route setObject:[PFUser currentUser] forKey:@"creator"];
        [route setObject:[PFGeoPoint geoPointWithLocation:self.currentLocation] forKey:@"location"];
        self.route = route;
        
        [route saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Dismiss the NewPostViewController and show the BlogTableViewController
                self.routeRatingField.text = @"";
                self.routeNameField.text = @"";
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving route" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
                [alert show];
            }
        }];
        
        [self performSegueWithIdentifier:@"showCheckInView" sender:self];
    }
}

#pragma Mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

#pragma Mark location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations objectAtIndex:0];
    
    int width = MAX(self.currentLocation.horizontalAccuracy, 50);
    int height = MAX(self.currentLocation.verticalAccuracy, 50);
    
    MKCoordinateRegion viewRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, width, height)];
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR");
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"Pause");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    CheckInViewController *checkInView = (CheckInViewController *)segue.destinationViewController;
    checkInView.route = self.route;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return NO;
}

@end
