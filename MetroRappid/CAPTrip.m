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
    self.realtime = [[CAPTripRealtime alloc] init];
    [self.realtime updateWithNextBusAPI:data[@"Realtime"]];
    self.block = data[@"Block"];
    self.exception = data[@"Exception"];
    self.atisStopId = data[@"Atisstopid"];
    self.stopId = data[@"Stopid"];
;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *now = [[NSDate alloc] init];
    NSString *estimated = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:now], data[@"Estimatedtime"]];
    
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    self.estimatedDate = [formatter dateFromString:estimated];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:self.estimatedDate];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    self.estimatedTime = [NSString stringWithFormat:@"%dm", (int)minute];

    if (hour > 1) self.estimatedTime = [NSString stringWithFormat:@"%dh %dm", (int)hour, (int)minute];

    NSLog(@"%@  estimated = %@", self.estimatedDate, estimated);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Trip: %@ scheduled: %@, estimated: %@, realtime: %@>", self.tripId, self.tripTime, self.estimatedTime, self.realtime.valid ? @"true" : @"false"];
}

@end
