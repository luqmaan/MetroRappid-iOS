//
//  CAPTrip.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPTrip.h"
#import "CAPModelUtils.h"
#import "GTFSDB.h"

@implementation CAPTrip

- (void)updateShape
{
    // TODO: use this https://github.com/luqmaan/ShapeReducer-objc
}

- (void)updateWithGTFS:(NSDictionary *)data
{
    self.blockId = data[@"block_id"];
    self.directionId = data[@"direction_id"];
    self.routeId = data[@"route_id"];
    self.serviceId = data[@"service_id"];
    self.shapeId = data[@"shape_id"];
    self.tripHeadsign = data[@"trip_headsign"];
    self.tripId = data[@"trip_id"];
    self.tripShortName = data[@"trip_short_name"];
    self.tripType = data[@"trip_type"];
    self.bikesAllowed = [data[@"bikes_allowed"] integerValue];
    self.wheelchairAccessible = [data[@"wheelchair_accessible"] integerValue];
}

- (void)updateWithNextBusAPI:(NSDictionary *)data
{
    self.publicRoute = data[@"Publicroute"];
    self.sign = data[@"Sign"];
    self.leOperator = data[@"Operator"];
    self.publicOperator = data[@"Publicoperator"];
    self.direction = data[@"Direction"];
    self.status = data[@"Status"];
    self.serviceType = data[@"Servicetype"];
    self.routeType = data[@"Routetype"];
    self.tripTime = data[@"Triptime"];
    self.tripId = data[@"Tripid"];
    self.skedTripId = data[@"Skedtripid"];
    self.adherence = data[@"Adherence"];
    self.realtime = [[CAPTripRealtime alloc] init];
    [self.realtime updateWithNextBusAPI:data[@"Realtime"]];
    self.block = data[@"Block"];
    self.exception = data[@"Exception"];
    self.atisStopId = data[@"Atisstopid"];
    self.stopId = data[@"Stopid"];

    NSDate *now = [[NSDate alloc] init];
    self.estimatedDate = [CAPModelUtils dateFromCapMetroTime:data[@"Estimatedtime"] withReferenceDate:now];
    self.estimatedTime = [CAPModelUtils timeBetweenStart:now andEnd:self.estimatedDate];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Trip: %@ scheduled: %@, estimated: %@, realtime: %@>", self.tripId, self.tripTime, self.estimatedTime, self.realtime.valid ? @"true" : @"false"];
}

@end
