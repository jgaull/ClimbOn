//
//  RouteViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/25/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "RouteViewController.h"
#import "RouteDataAnnotation.h"

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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Post"];
    [query whereKey:@"route" equalTo:self.routeData];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"creator"];
    [query includeKey:@"route"];
    [query includeKey:@"route.rating"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.posts = [[NSArray alloc] initWithArray:objects];
            [self.tableView reloadData];
        }
    }];
    
    RouteDataAnnotation *annotation = [[RouteDataAnnotation alloc] initWithRouteData:self.routeData];
    [self.mapView addAnnotation:annotation];
    CLLocationDistance visibleDistance = 100; //100 kilometers
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, visibleDistance, visibleDistance);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    
    [self.mapView setRegion:adjustedRegion animated:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMap:)];
    [self.mapView addGestureRecognizer:tapGesture];
    self.expandedMap = false;
}
     
- (void)onTapMap:(id)sender {
    
    self.expandedMap = !self.expandedMap;
    float height = self.expandedMap ? 100 : self.view.frame.size.height;
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.posts.count;
}

/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *postData = [self.posts objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"CheckIn";
    CheckInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    
    cell.creator = [postData objectForKey:@"creator"];
    cell.routeData = [postData objectForKey:@"route"];
    cell.ratingData = [cell.routeData objectForKey:@"rating"];
    cell.postData = postData;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *postData = [self.posts objectAtIndex:indexPath.row];
#warning Comments is just nil here because this class should subclass the feed view.
    return [CheckInCell getHeightForCellFromPostData:postData andComments:nil];
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
