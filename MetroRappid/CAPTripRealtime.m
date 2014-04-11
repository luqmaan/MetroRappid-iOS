//
//  CAPTripRealtime.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPTripRealtime.h"
#import "CAPModelUtils.h"

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

    NSDate *now = [[NSDate alloc] init];
    self.estimatedDate = [CAPModelUtils dateFromCapMetroTime:data[@"Estimatedtime"] withReferenceDate:now];
    self.estimatedTime = [CAPModelUtils timeBetweenStart:now andEnd:self.estimatedDate];

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
