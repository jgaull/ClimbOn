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

@interface AddRouteViewController ()

@property (strong, nonatomic) IBOutlet UITextField *routeNameField;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSNumber *routeLat;
@property (strong, nonatomic) NSNumber *routeLon;
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
    self.locationManager = nil;
}

#pragma Mark Touch event listeners

- (IBAction)onSaveButton:(UIButton *)sender {
    
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
        
        [route setObject:self.routeNameField.text forKey:@"name"];
        [route setObject:[PFUser currentUser] forKey:@"creator"];
        [route setObject:[PFGeoPoint geoPointWithLocation:self.currentLocation] forKey:@"location"];
        self.route = route;
        
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
    NSLog(@"didUpdateLocations");
    if(self.currentLocation == nil) {
        self.currentLocation = [locations objectAtIndex:0];
        [self updateMap];
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
    NSLog(@"region will change animated:%s", animated ? "true" : "false");
    if(self.currentLocation != nil && animated == NO)
        self.userOverride = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated");
//    [self updateMap];
    if(self.userOverride == YES){
        MKCoordinateRegion viewRegion = [self getMapRegion];
        self.routeLat = [NSNumber numberWithDouble:viewRegion.center.latitude];
        self.routeLon = [NSNumber numberWithDouble:viewRegion.center.longitude];
//        NSLog(@"user has set map to:%d, %d", self.routeLat, self.routeLon);
    }
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"did udpate user location");
    
    if(self.userOverride == NO)
        [self updateMap];
}

- (void)updateMap
{
    if(self.currentLocation != nil) {
        MKCoordinateRegion viewRegion = [self getMapRegion];
        [self.mapView setRegion:viewRegion animated:YES];
    }
}

- (MKCoordinateRegion)getMapRegion {
    int width = MAX(self.currentLocation.horizontalAccuracy, 50);
    int height = MAX(self.currentLocation.verticalAccuracy, 50);
    
    return [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, width, height)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    CheckInViewController *checkInView = (CheckInViewController *)segue.destinationViewController;
    checkInView.route = self.route;
    checkInView.postType = self.postType;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return NO;
}

@end
