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
    self.stopId = data[@"stop_id"];
    self.lat = data[@"stop_lat"];
    self.lon = data[@"stop_lon"];
    self.name = [self formatString:data[@"stop_name"]];
    self.desc = data[@"stop_desc"];
    self.headsign = [data[@"trip_headsign"] capitalizedString];
    NSLog(@"updating with dict %@", data);
}

- (NSString *)formatString:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"(NB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(SB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(EB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(WB)" withString:@""];
    return [str capitalizedString];
}

@end
