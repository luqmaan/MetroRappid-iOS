//
//  CAPTripRealtime.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPTripRealtime.h"

@implementation CAPTripRealtime

- (id)initWithNextBusAPI:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.valid = data[@"Valid"];
        self.adherence = data[@"Adherence"];
        self.estimatedTime = data[@"Estimatedtime"];
        self.estimatedMinutes = data[@"Estimatedminutes"];
        self.polltime = data[@"Polltime"];
        self.trend = data[@"Trend"];
        self.speed = data[@"Speed"];
        self.reliable = data[@"Reliable"];
        self.stopped = data[@"Stopped"];
        self.vehicleId = data[@"Vehicleid"];
        self.lat = data[@"Lat"];
        self.lon = data[@"Long"];
    }
    return self;
}

@end
