//
//  RouteViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/25/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "RouteViewController.h"
#import "RouteDataAnnotation.h"
#import "Constants.h"

#import <MapKit/MapKit.h>

@interface RouteViewController ()

@property (nonatomic, strong) NSArray *posts;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) BOOL expandedMap;

@end

@implementation RouteViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    PFQuery *query = [[PFQuery alloc] initWithClassName:kClassPost];
    [query whereKey:kKeyPostRoute equalTo:self.routeData];
    self.query = query;
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    RouteDataAnnotation *annotation = [[RouteDataAnnotation alloc] initWithRouteData:self.routeData];
    [self.mapView addAnnotation:annotation];
    CLLocationDistance visibleDistance = 100; //kilometers
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, visibleDistance, visibleDistance);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    
    [self.mapView setRegion:adjustedRegion animated:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMap:)];
    [self.mapView addGestureRecognizer:tapGesture];
    self.expandedMap = false;
}
     
- (void)onTapMap:(id)sender {
    
    self.expandedMap = !self.expandedMap;
    float height = self.expandedMap ? 75 : self.view.frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.mapView setFrame:CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, height)];
    }];
    
    [self recenterMapAnimated:YES];
}

- (void)recenterMapAnimated:(BOOL)animated {
    RouteDataAnnotation *annotation = [[RouteDataAnnotation alloc] initWithRouteData:self.routeData];
    CLLocationDistance visibleDistance = 100; //100 kilometers
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, visibleDistance, visibleDistance);
    MKCoordinateRegion viewRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:viewRegion animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    self.posts = nil;
    self.mapView = nil;
    self.routeData = nil;
}

@end
