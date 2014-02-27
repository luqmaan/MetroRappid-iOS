//
//  CAPStop.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPStop.h"

@implementation CAPStop

- (id)init
{
    self = [super init];
    if (self) {
        self.trips = [[NSMutableArray alloc] init];
        self.showsMap = NO;
    }
    return self;
}

- (void)updateWithGTFS:(NSDictionary *)data
{
    self.distance = [data[@"distance"] floatValue];
    self.routeId = data[@"route_id"];
    self.stopId = data[@"stop_id"];
    self.tripId = data[@"trip_id"];
    self.shapeId = data[@"shape_id"];
    self.lat = data[@"stop_lat"];
    self.lon = data[@"stop_lon"];
    self.name = [self formatString:data[@"stop_name"]];
    self.desc = data[@"stop_desc"];
    self.headsign = [data[@"trip_headsign"] capitalizedString];
    self.stopSequence = [data[@"stop_sequence"] intValue];
    if ([self.headsign isEqualToString:@"Northbound"]) {
        self.directionId = 0;
    }
    else if ([self.headsign isEqualToString:@"Southbound"]) {
        self.directionId = 1;
    }
    else {
        NSLog(@"WTF Direction %@ %@", self.headsign, data[@"directionId"]);
    }
//    self.directionId = [data[@"direction_id"] intValue];
    
}

- (NSString *)formatString:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"(NB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(SB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(EB)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(WB)" withString:@""];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [str capitalizedString];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Stop: %@ %@ - %d %@ %@ - tripId: %@ with %d trips, sequence: %d>", self.routeId, self.name, self.directionId, self.headsign, self.stopId, self.tripId, (int)self.trips.count, self.stopSequence];
}

@end

@implementation CAPLocation

- (id)init {
    self = [super init];
    if (self) {
        self.stops = [[NSMutableArray alloc] init];
        self.stopIds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateWithGTFS:(NSDictionary *)data
{
    CAPStop *stop = [[CAPStop alloc] init];
    [stop updateWithGTFS:data];

    [self updateWithStop:stop];
}

- (void)updateWithStop:(CAPStop *)stop
{
    if (!self.name || !self.routeId) {
        // the first one always belongs here
        self.name = stop.name;
        self.routeId = stop.routeId;
        self.distance = stop.distance;
    }
    if ([self stopBelongsHere:stop]) {
        [self.stopIds addObject:stop.stopId];
        [self.stops addObject:stop];
        self.distance = MIN(self.distance, stop.distance);
    }
}

- (BOOL)stopBelongsHere:(CAPStop *)stop
{
    // Make sure data really does belong to this stop
    if (![self.name isEqualToString:stop.name]) {
        // FIXME: throw error?
        NSLog(@"Error: Stop does not belong to location, incorrect name: `%@` != `%@`", self.name, stop.name);
        return NO;
    }
    if (![self.routeId isEqualToString:stop.routeId]) {
        // FIXME: throw error?
        NSLog(@"Error: Stop does not belong to location, incorrect route id:  `%@` != `%@`", self.routeId, stop.routeId);
        return NO;
    }
    
    // Don't add same stop multiple times
    if ([self.stopIds containsObject:stop.stopId]) {
        NSLog(@"Error: Stop does not belong, duplicate stop");
        return NO;
    }
    
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<Location: %@ %@ %f km distance with %lu stops %@>", self.routeId, self.name, self.distance, (unsigned long)self.stops.count, self.stopIds];
}

@end
