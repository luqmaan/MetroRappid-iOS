//
//  GTFSDBTests.m
//  MetroRappid
//
//  Created by Luq on 4/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GTFSDB.h"
#import "CAPStop.h"

@interface CAPGTFSDatabaseTests : XCTestCase

@property GTFSDB *gtfs;
@property CLLocation *location;

@end

@implementation CAPGTFSDatabaseTests

- (void)setUp
{
    [super setUp];

    self.location = [[CLLocation alloc] initWithLatitude:30.267153 longitude:-97.743061];

    self.gtfs = [[GTFSDB alloc] init];
    while (!self.gtfs.ready) ;
}

- (void)testGTFSDB_CanFindNearbyLocationsForMultipleRoutes
{
    NSMutableArray *stops = [self.gtfs locationsForRoutes:@[@801] nearLocation:self.location inDirection:GTFSSouthbound];
    
    XCTAssertEqual((NSUInteger)23, stops.count);
    
    for (CAPStop *stop in stops) {
        XCTAssertTrue([@"801" isEqualToString:stop.routeId]);
        XCTAssertTrue([@"Southbound" isEqualToString:stop.headsign]);
    }
    
    CAPStop *route801TechRidge = stops[0];
    CAPStop *route801Chinatown = stops[1];
    CAPStop *route801RepublicSquare = stops[14];
    CAPStop *route801SouthParkMeadows = stops[22];
    
    XCTAssertTrue([@"Tech Ridge Bay I" isEqualToString:route801TechRidge.name]);
    XCTAssertTrue([@"Chinatown Station" isEqualToString:route801Chinatown.name]);
    XCTAssertTrue([@"Republic Square Station" isEqualToString:route801RepublicSquare.name]);
    XCTAssertTrue([@"Southpark Meadows Station" isEqualToString:route801SouthParkMeadows.name]);
    
    XCTAssertTrue([@"5304" isEqualToString:route801TechRidge.stopId]);
    XCTAssertTrue([@"5857" isEqualToString:route801Chinatown.stopId]);
    XCTAssertTrue([@"5867" isEqualToString:route801RepublicSquare.stopId]);
    XCTAssertTrue([@"5873" isEqualToString:route801SouthParkMeadows.stopId]);
}

- (void)testGTFSDB_AuditoriumShoresNorthIsDifferentFromSouth
{
    NSMutableArray *southStops = [self.gtfs locationsForRoutes:@[@801] nearLocation:self.location inDirection:GTFSSouthbound];
    NSMutableArray *northStops = [self.gtfs locationsForRoutes:@[@801] nearLocation:self.location inDirection:GTFSNorthbound];
    
    XCTAssertEqual((NSUInteger)23, southStops.count);
    XCTAssertEqual((NSUInteger)23, northStops.count);
    
    CAPStop *auditoriumShoresNorth = northStops[7];
    CAPStop *auditoriumShoresSouth = southStops[15];
    
    XCTAssertTrue([@"Auditorium Shores Station" isEqualToString:auditoriumShoresNorth.name]);
    XCTAssertTrue([@"Auditorium Shores Station" isEqualToString:auditoriumShoresSouth.name]);
    
    XCTAssertTrue([@"Auditorium Shores Station" isEqualToString:auditoriumShoresNorth.name]);
    XCTAssertTrue([@"Auditorium Shores Station" isEqualToString:auditoriumShoresSouth.name]);
    
    XCTAssertTrue([@"2767" isEqualToString:auditoriumShoresNorth.stopId]);
    XCTAssertTrue([@"2763" isEqualToString:auditoriumShoresSouth.stopId]);
}

@end
