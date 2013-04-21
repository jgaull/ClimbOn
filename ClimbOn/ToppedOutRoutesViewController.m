//
//  ToppedOutRoutesViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 4/21/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "ToppedOutRoutesViewController.h"
#import "ClimbOnUtils.h"

@interface ToppedOutRoutesViewController ()

@end

@implementation ToppedOutRoutesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // The className to query on
    self.className = @"Route";
    
    // The key of the PFObject to display in the label of the default cell style
    self.textKey = @"name";
    
    // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
    // self.imageKey = @"image";
    
    // Whether the built-in pull-to-refresh is enabled
    self.pullToRefreshEnabled = NO;
    
    // Whether the built-in pagination is enabled
    self.paginationEnabled = YES;
    
    // The number of objects to show per page
    self.objectsPerPage = 50;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    PFObject *route = [object objectForKey:@"route"];
    cell.textLabel.text = [route objectForKey:self.textKey];
    
    return cell;
}

- (PFQuery *)queryForTable {
    PFQuery *topOutsQuery = [ClimbOnUtils getTopoutsQueryForUser:[PFUser currentUser]];
    [topOutsQuery includeKey:@"route"];
    [topOutsQuery orderByDescending:@"createdAt"];
    return topOutsQuery;
}

@end
