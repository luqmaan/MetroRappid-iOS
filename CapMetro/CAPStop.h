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
@property NSString *lat;
@property NSString *lon;
@property NSString *name;
@property NSString *headsign;
@property NSString *desc;
@property NSString *stopSequence;
/** Array of CAPTrips */
@property NSMutableArray *trips;
@property NSDate *lastUpdated;

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
@property (nonatomic, assign) float distance;

@end

