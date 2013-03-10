//
//  FirstAscentViewController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/23/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "FirstAscentViewController.h"

@interface FirstAscentViewController ()

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSArray *ratings;

@property (nonatomic) int numRatings;

@end

@implementation FirstAscentViewController

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Rating"];
    [query orderByAscending:@"difficulty"];
    [query whereKey:@"ratingSystem" notEqualTo:@"unrated"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSMutableArray *ratingNames = [[NSMutableArray alloc] init];
        
        for (PFObject *rating in objects) {
            NSString *ratingSystem = [rating objectForKey:@"ratingSystem"];
            NSMutableArray *ratingsArray = [dict objectForKey:ratingSystem];
            if ([dict objectForKey:ratingSystem] == nil) {
                [dict setObject:[[NSMutableArray alloc] init] forKey:ratingSystem];
                [ratingNames addObject:ratingSystem];
            }
            
            [ratingsArray addObject:rating];
        }
        
        self.numRatings = objects.count;
        self.data = [[NSDictionary alloc] initWithDictionary:dict];
        self.ratings = [[NSArray alloc] initWithArray:ratingNames];
        [self.pickerView reloadAllComponents];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDoneButton:(id)sender {
    PFObject *rating = [[self getRatingNamesForSelectedRatingSystem] objectAtIndex:[self.pickerView selectedRowInComponent:1]];
    
    [self.route setObject:[PFUser currentUser] forKey:@"firstAscent"];
    [self.route setObject:rating forKey:@"rating"];
    
    [self.route saveEventually];
    [self.post saveEventually];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma Mark Picker View Delegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        return [self.ratings objectAtIndex:row];
    }
    
    PFObject *ratingData = [[self getRatingNamesForSelectedRatingSystem] objectAtIndex:row];
    return [ratingData objectForKey:@"name"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.ratings.count;
    }
    
    return [self getRatingNamesForSelectedRatingSystem].count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [self.pickerView reloadComponent:1];
    }
}

- (NSArray *)getRatingNamesForSelectedRatingSystem {
    NSString *ratingSystemName = [self.ratings objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    return [self.data objectForKey:ratingSystemName];
}

-(void)dealloc {
    self.pickerView = nil;
    self.data = nil;
    self.ratings = nil;
    self.route = nil;
    self.post = nil;
}

@end
