//
//  RouteDataAnnotation.h
//  ClimbOn
//
//  Created by Jonathan Gaull on 2/26/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface RouteDataAnnotation : NSObject <MKAnnotation>

@property (nonatomic, weak) PFObject *routeData;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithRouteData:(PFObject *)routeData;

@end
