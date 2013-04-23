//
//  NearbyRoutesViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/17/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "NearbyRoutesViewController.h"
#import "CheckInViewController.h"
#import "AddRouteViewController.h"
#import "RouteViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface NearbyRoutesViewController ()

@property (nonatomic, strong) NSDictionary *ratings;
@property (nonatomic, strong) NSArray *ratingTypesList;

@property (nonatomic, strong) NSIndexPath *rowSelectedWithDisclosure;

@end

@implementation NearbyRoutesViewController

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
    
    self.title = @"Nearby";
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            PFQuery *query = [[PFQuery alloc] initWithClassName:@"Route"];
            [query whereKey:kKeyUserLocation nearGeoPoint:geoPoint withinMiles:1];
            [query includeKey:@"rating"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSMutableDictionary *tempRatingsLookup = [[NSMutableDictionary alloc] init];
                NSMutableArray *tempRatingTypeList = [[NSMutableArray alloc] init];
                
                for (PFObject *routeData in objects) {
                    PFObject *ratingData = [routeData objectForKey:@"rating"];
                    NSMutableArray *routesOfRating = [tempRatingsLookup objectForKey:ratingData.objectId];
                    if (routesOfRating == nil) {
                        routesOfRating = [[NSMutableArray alloc] init];
                        [tempRatingsLookup setObject:routesOfRating forKey:ratingData.objectId];
                        [tempRatingTypeList addObject:ratingData];
                    }
                    
                    [routesOfRating addObject:routeData];
                }
                
                self.ratings = tempRatingsLookup;
                self.ratingTypesList = tempRatingTypeList;
                [self.tableView reloadData];
            }];
        }
        else {
            
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    self.ratings = nil;
    self.ratingTypesList = nil;
    self.rowSelectedWithDisclosure = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ratings.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    NSString *ratingType = [self.ratingTypesList objectAtIndex:section - 1];
    return ((NSArray *)[self.ratings objectForKey:((PFObject *)ratingType).objectId]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    PFObject *ratingData = [self.ratingTypesList objectAtIndex:section - 1];
    return [ratingData objectForKey:@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    
    if (indexPath.section == 0) {
        cellIdentifier = @"createNew";
    }
    else {
        cellIdentifier = @"existingRoute";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section > 0) {
        PFObject *routeData = [self getRouteDataForIndexPath:indexPath];
        PFObject *rating = [routeData objectForKey:@"rating"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [routeData objectForKey:@"name"], [rating objectForKey:@"name"]];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //something is broken so using a normal storyboard segue didn't work. self.table.indexPathForSelectedRow was always nil
    self.rowSelectedWithDisclosure = indexPath;
    [self performSegueWithIdentifier:@"viewRoute" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"checkInAtRoute"]) {
        CheckInViewController *checkInView = (CheckInViewController *)segue.destinationViewController;
        checkInView.route = [self getRouteDataForIndexPath:self.tableView.indexPathForSelectedRow];
    }
    else if ([segue.identifier isEqualToString:@"viewRoute"]) {
        RouteViewController *routeView = (RouteViewController *)segue.destinationViewController;
        routeView.routeData = [self getRouteDataForIndexPath:self.rowSelectedWithDisclosure];
    }
}

- (IBAction)onCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFObject *)getRouteDataForIndexPath:(NSIndexPath *)indexPath {
    PFObject *ratingType = [self.ratingTypesList objectAtIndex:indexPath.section - 1];
    return [[self.ratings objectForKey:ratingType.objectId] objectAtIndex:indexPath.row];
}

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
