//
//  AutoRotationNavigationController.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 3/10/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AutoRotationNavigationController.h"
#import "FeedViewController.h"

@interface AutoRotationNavigationController ()

@end

@implementation AutoRotationNavigationController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    if ([self.visibleViewController isKindOfClass:[FeedViewController class]]) {
        return [self.visibleViewController shouldAutorotate];
    }
    
    else return NO;
}

@end
