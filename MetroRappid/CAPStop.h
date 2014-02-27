//
//  CAPStop.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CAPStop: NSObject

@property (nonatomic, assign) float distance;
@property NSString *routeId;
@property NSString *stopId;
@property NSString *tripId;
@property NSString *shapeId;
@property NSString *lat;
@property NSString *lon;
@property NSString *name;
@property NSString *headsign;
@property NSString *desc;
@property (nonatomic, assign) int stopSequence;
/** Always 0 or 1, for Austin */
@property (nonatomic, assign) int directionId;
/** Array of CAPTrips */
@property NSMutableArray *trips;
@property NSDate *lastUpdated;

@property BOOL showsMap;

- (void)updateWithGTFS:(NSDictionary *)data;

@end


// Groups of stops that share the same route and name
// Usually differ by headisng/direction, e.g. southbound
@interface CAPLocation : NSObject

- (void)updateWithGTFS:(NSDictionary *)data;
- (void)updateWithStop:(CAPStop *)stop;
- (BOOL)stopBelongsHere:(CAPStop *)stop;

@property NSMutableArray *stops;
@property NSMutableArray *stopIds;
@property NSString *name;
@property NSString *routeId;
/** Index as a number relative to other locations, 0 being closest. */
@property (nonatomic, assign) int distanceIndex;
@property (nonatomic, assign) float distance;

@end

