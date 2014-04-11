//
//  CAPStop.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPStop.h"
#import <MapKit/MapKit.h>

@implementation CAPStop

@synthesize coordinate;

- (id)init
{
    self = [super init];
    if (self) {
        self.trips = [[NSMutableArray alloc] init];
        self.showsTrips = NO;
    }
    return self;
}

- (void)updateWithGTFS:(NSDictionary *)data
{
    self.distance = [data[@"distance"] floatValue];
    MKDistanceFormatter *df = [[MKDistanceFormatter alloc]init];
    df.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
    CLLocationDistance dist = 1000 * self.distance;
    self.distancePretty = [df stringFromDistance:dist];
    self.routeId = data[@"route_id"];
    self.stopId = data[@"stop_id"];
    self.tripId = data[@"trip_id"];
    self.shapeId = data[@"shape_id"];
    self.lat = [data[@"stop_lat"] floatValue];
    self.lon = [data[@"stop_lon"] floatValue];
    if (self.lat && self.lon) {
        coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
    }
    self.name = [self formatString:data[@"stop_name"]];
    self.desc = data[@"stop_desc"];
    self.stopSequence = [data[@"stop_sequence"] intValue];
    self.headsign = [data[@"trip_headsign"] capitalizedString];
    if ([self.headsign isEqualToString:@"Northbound"]) {
        self.directionId = 0;
    }
    else if ([self.headsign isEqualToString:@"Southbound"]) {
        self.directionId = 1;
    }
    else {
        NSLog(@"WTF Direction %@ %@", self.headsign, data[@"directionId"]);
    }
    self.title = [NSString stringWithFormat:@"%@", self.name];
    self.subtitle = [NSString stringWithFormat:@"Stop #%@ %@", self.stopId, self.desc];
}

- (NSString *)formatString:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"(NB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(SB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(EB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(WB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"CRESTIVIEW" withString:@"Crestview"];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [str capitalizedString];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Stop: %@ %@ - %d %@ stopId: %@ - tripId: %@ with %d trips, sequence: %d>", self.routeId, self.name, self.directionId, self.headsign, self.stopId, self.tripId, (int)self.trips.count, self.stopSequence];
}

@end
