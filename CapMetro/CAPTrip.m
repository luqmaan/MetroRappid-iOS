//
//  CAPTrip.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPTrip.h"

@implementation CAPTrip

- (void)updateWithNextBusAPI:(NSDictionary *)data
{
    self.route = data[@"Route"];
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
    self.estimatedTime = data[@"Estimatedtime"];
    self.realtime = [[CAPTripRealtime alloc] init];
    [self.realtime updateWithNextBusAPI:data[@"Realtime"]];
    self.block = data[@"Block"];
    self.exception = data[@"Exception"];
    self.atisStopId = data[@"Atisstopid"];
    self.stopId = data[@"Stopid"];
}

@end
