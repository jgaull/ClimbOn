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
#import "RouteAnnotationView.h"
#import "RouteAnnotation.h"
#import "Constants.h"

@interface AddRouteViewController ()

@property (strong, nonatomic) IBOutlet UITextField *routeNameField;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *marker;
@property (weak, nonatomic) IBOutlet UIImageView *markerShadow;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) CLLocationDegrees routeLat;
@property (nonatomic) CLLocationDegrees routeLon;
@property (strong, nonatomic) PFObject *route;
@property (nonatomic) BOOL userOverride;

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
    self.userOverride = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.routeNameField = nil;
    self.mapView = nil;
    self.marker = nil;
    self.markerShadow = nil;
    self.locationManager = nil;
    self.currentLocation = nil;
    self.route = nil;
}

#pragma Mark Touch event listeners

- (IBAction)onDoneButton:(UIBarButtonItem *)sender {
    if (self.routeNameField.isFirstResponder) {
        [self.routeNameField resignFirstResponder];
    }
    else {
        UIAlertView *alert;
        if ([self.routeNameField.text isEqualToString:@""]) {
            alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please give the route a name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        else
        {
            PFObject *route = self.route;
            
            if (!route) {
                route = [PFObject objectWithClassName:@"Route"];
            }
            
            [route setObject:self.routeNameField.text forKey:kKeyRouteName];
            [route setObject:[PFUser currentUser] forKey:kKeyRouteCreator];
            
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
            [route setObject:point forKey:kKeyRouteLocation];
            
            PFObject *rating = [[PFObject alloc] initWithClassName:kClassRating];
            rating.objectId = @"OJewnFZKQ4";
            [route setObject:rating forKey:kKeyRouteRating];
            
            self.route = route;
            
            [self performSegueWithIdentifier:@"checkInAtRoute" sender:self];
        }
    }
}

#pragma Mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

#pragma Mark location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"didUpdateLocations");
    if(self.userOverride == NO) {
        self.currentLocation = [locations objectAtIndex:0];
        MKCoordinateRegion viewRegion = [self getMapRegionWithCoordinate:self.currentLocation.coordinate];
        [self.mapView setRegion:viewRegion animated:YES];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR");
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"Pause");
}

#pragma Map view delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    NSLog(@"region will change animated:%s", animated ? "true" : "false");
    if(self.currentLocation != nil && animated == NO)
    {
        self.userOverride = YES;
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             CGRect frame = self.marker.frame;
                             frame.origin.y = frame.origin.y - 10;
                             self.marker.frame = frame;
                             self.marker.alpha = 0.8;
                             self.markerShadow.alpha = 0.3;
                         }
                         completion:NULL];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    NSLog(@"regionDidChangeAnimated");
//    [self updateMap];
    if(self.userOverride == YES){
        CLLocationCoordinate2D loc = self.mapView.region.center;
        self.routeLat = loc.latitude;
        self.routeLon = loc.longitude;
        
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             CGRect frame = self.marker.frame;
                             frame.origin.y = frame.origin.y + 10;
                             self.marker.frame = frame;
                             self.marker.alpha = 1;
                             self.markerShadow.alpha = 1;
                         }
                         completion:NULL];
//        NSLog(@"user has set map to:%d, %d", self.routeLat, self.routeLon);
    }
}

- (MKCoordinateRegion)getMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate {
    int width = MAX(self.currentLocation.horizontalAccuracy, 50);
    int height = MAX(self.currentLocation.verticalAccuracy, 50);
    
    return [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(coordinate, width, height)];
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
