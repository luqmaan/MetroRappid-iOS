//
//  CAPTrip.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAPTripRealtime.h"

@interface CAPTrip : NSObject

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
@property NSString *tripId;
@property NSString *skedTripId;
@property NSString *adherence;
@property NSString *estimatedTime;
@property NSString *block;
@property NSString *exception;
@property NSString *atisStopId;
@property NSString *stopId;

@property CAPTripRealtime *realtime;

- (void)updateWithNextBusAPI:(NSDictionary *)data;

@end
