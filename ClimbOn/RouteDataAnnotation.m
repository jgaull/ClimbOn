//
//  RouteDataAnnotation.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/26/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "RouteDataAnnotation.h"
#import "Constants.h"

@implementation RouteDataAnnotation

- (id)initWithRouteData:(PFObject *)routeData {
    self = [super init];
    if (self) {
        self.routeData = routeData;
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    PFGeoPoint *routeLocation = [self.routeData objectForKey:kKeyUserLocation];
    return CLLocationCoordinate2DMake(routeLocation.latitude, routeLocation.longitude);
}

- (NSString *)subtitle {
    return nil;
}

- (NSString *)title {
    return [NSString stringWithString:[self.routeData objectForKey:@"name"]];
}

-(void)dealloc {
    self.routeData = nil;
}

@end
