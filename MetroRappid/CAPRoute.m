//
//  CAPRoute.m
//  MetroRappid
//
//  Created by Luq on 5/17/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRoute.h"
#import "GTFSDB.h"


@interface CAPRoute ()

@end


@implementation CAPRoute

- (id)initWithRouteId:(NSString *)routeId
{
    if (self = [super init]) {
        _routeId = routeId;
        _distance = 0.0f;
    }
    return self;
}

- (void)update
{
    if (!self.gtfsData) {
        self.gtfsData = [GTFSDB routeWithId:self.routeId];
    }

    self.agencyId = self.gtfsData[@"agency_id"];
    self.routeShortName = self.gtfsData[@"route_short_name"];
    self.routeLongName = self.gtfsData[@"route_long_name"];
    self.routeDesc = self.gtfsData[@"route_desc"];
    self.routeType = (GTFSRouteType)[self.gtfsData[@"route_type"] intValue];
    self.routeUrl = self.gtfsData[@"route_url"];
    self.routeColor = self.gtfsData[@"route_color"];
    self.routeTextColor = self.gtfsData[@"route_text_color"];
}

@end
