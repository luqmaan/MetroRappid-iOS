//
//  CAPTrip.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPTrip.h"

@implementation CAPTrip

- (id)initWithNextBusAPI:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        NSLog(@"Creating trip");
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
        self.realtime = [[CAPTripRealtime alloc] initWithNextBusAPI:data[@"Realtime"]];
        self.block = data[@"Block"];
        self.exception = data[@"Exception"];
        self.atisStopId = data[@"Atisstopid"];
        self.stopId = data[@"Stopid"];
    }
    return self;
}

@end
