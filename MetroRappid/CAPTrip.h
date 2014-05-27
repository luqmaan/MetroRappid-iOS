//
//  CAPTrip.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAPTripRealtime.h"
#import "CAPShape.h"

@interface CAPTrip : NSObject

@property CAPShape *shape;

// gtfs
@property NSString *blockId;
@property NSString *directionId;
@property NSString *routeId;
@property NSString *serviceId;
@property NSString *shapeId;
@property NSString *tripHeadsign;
@property NSString *tripId;
@property NSString *tripShortName;
@property NSString *tripType;
@property (nonatomic, assign) NSInteger bikesAllowed;
@property (nonatomic, assign) NSInteger wheelchairAccessible;

// nextbus
@property NSString *route;
@property NSString *publicRoute;
@property NSString *sign;
@property NSString *leOperator;
@property NSString *publicOperator;
@property NSString *direction;
@property NSString *status;
@property NSString *serviceType;
@property NSString *routeType;
@property NSString *tripTime; // FIXME: Use NSDate
@property NSString *skedTripId;
@property NSString *adherence;
@property NSDate *estimatedDate;
@property NSString *estimatedTime;
@property NSString *block;
@property NSString *exception;
@property NSString *atisStopId;
@property NSString *stopId;

@property CAPTripRealtime *realtime;

- (void)updateWithGTFS:(NSDictionary *)data;
- (void)updateWithNextBusAPI:(NSDictionary *)data;

@end
