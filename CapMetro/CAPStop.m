//
//  CAPStop.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPStop.h"

@implementation CAPStop

- (void)updateWithGTFS:(NSDictionary *)data
{
    self.distance = data[@"distance"];
    self.routeId = data[@"route_id"];
    self.desc = data[@"stop_desc"];
    self.stopId = data[@"stop_id"];
    self.lat = data[@"stop_lat"];
    self.lon = data[@"stop_lon"];
    self.name = [data[@"stop_name"] capitalizedString];
}

@end
