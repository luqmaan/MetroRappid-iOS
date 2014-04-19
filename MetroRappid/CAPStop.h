//
//  CAPStop.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#pragma mark - CAPSTop

@interface CAPStop: NSObject <MKAnnotation>

/** Relative distance to other stops this stop was created with, assigned by GTFSDB */
@property (nonatomic, assign) int distanceIndex;  // FIXME: This probably shouldn't exist. Instead whatever acceses this should just compute/cache it as needed.

@property (nonatomic, assign) float distance;  // FIXME: Use CLLocationDistance
@property NSString *distancePretty;
@property NSString *routeId;
@property NSString *stopId;
@property NSString *tripId;
@property NSString *shapeId;
@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lon;
@property NSString *name;
@property NSString *headsign;
@property NSString *desc;
@property (nonatomic, assign) int stopSequence;
/** Always 0 or 1, for Austin */
@property (nonatomic, assign) int directionId;
/** Array of CAPTrips */
@property NSMutableArray *trips;
@property NSDate *lastUpdated;

@property BOOL showsTrips;  // FIXME: Putting this as a property on the model seems bad

- (void)updateWithGTFS:(NSDictionary *)data;

#pragma mark - CAPStop MKAnnotation

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
