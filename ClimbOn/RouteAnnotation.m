
#import "RouteAnnotation.h"

@implementation RouteAnnotation

#warning This is a duplicate class

- (CLLocationCoordinate2D)coordinate
{
    coordinate.longitude = [self.longitude doubleValue];
    coordinate.latitude = [self.latitude doubleValue];
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
{
    self.longitude = [NSNumber numberWithDouble:newCoordinate.longitude];
    self.latitude = [NSNumber numberWithDouble:newCoordinate.latitude];
}

@end
