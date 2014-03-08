//
//  CAPTripRealtime.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPTripRealtime.h"

@implementation CAPTripRealtime

@synthesize coordinate;  // Why this is needed, I do not know :(

- (void)updateWithNextBusAPI:(NSDictionary *)data
{
    self._data = data;
    self.valid = [data[@"Valid"] boolValue];
    self.adherence = data[@"Adherence"];
    self.estimatedMinutes = data[@"Estimatedminutes"];
    self.polltime = data[@"Polltime"];
    self.trend = data[@"Trend"];
    self.speed = data[@"Speed"];
    self.reliable = data[@"Reliable"];
    self.stopped = data[@"Stopped"];
    self.vehicleId = data[@"Vehicleid"];
    if (data[@"Lat"]) self.lat = [data[@"Lat"] floatValue];
    if (data[@"Long"]) self.lon = [data[@"Long"] floatValue];
    if (self.lat && self.lon) {
        coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
    }

    // Convert the EstimatedTime string to NSDate
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *now = [[NSDate alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *estimated = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:now], data[@"Estimatedtime"]];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    self.estimatedDate = [formatter dateFromString:estimated];
    
    // Get the time difference between now and estimatedDate
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:now toDate:self.estimatedDate options:0];
    
    // Stringify it
    self.estimatedTime = [NSString stringWithFormat:@"%dm", (int)components.minute];
    if (components.hour > 1) self.estimatedTime = [NSString stringWithFormat:@"%dh %dm", (int)components.hour, (int)components.minute];
    [self updateTitle];
}

- (void)updateTitle
{
    self.title = [NSString stringWithFormat:@"%@ Away - Vehicle %@", self.estimatedTime, self.vehicleId];
    self.subtitle = [NSString stringWithFormat:@"Location Updated %@", self.polltime];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<CAPTripRealtime: coordinate = %f %f; Estimatedtime = %@; estimatedMinutes = %@; >", (float)coordinate.latitude, (float)coordinate.longitude, self.estimatedTime, self.estimatedMinutes];
}

@end
