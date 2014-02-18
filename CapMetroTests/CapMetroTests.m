//
//  CapMetroTests.m
//  CapMetroTests
//
//  Created by Luq on 2/9/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <XMLDictionary/XMLDictionary.h>
#import "CAPNextBus.h"
#import "CAPTrip.h"
#import "CAPTripRealtime.h"
#import "GTFSDB.h"
#import "CAPStop.h"

@interface CapMetroTests : XCTestCase

@end

@implementation CapMetroTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGTFSDB_CanFindNearbyLocationsForMultipleRoutes
{
    GTFSDB *gtfs = [[GTFSDB alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:30.267153 longitude:-97.743061];

    NSMutableArray *locations = [gtfs locationsForRoutes:@[@801, @1] nearLocation:loc withinRadius:1.0f];

    for (CAPLocation *loc in locations) {
        NSLog(@"%@", loc);
    }
    
    XCTAssertEqual((NSUInteger)21, locations.count);
    CAPLocation *route1Congress5th = locations[0];
    CAPLocation *route801RepublicSquare = locations[7];

    XCTAssertTrue([@"425 Congress/5Th" isEqualToString:route1Congress5th.name]);
    XCTAssertTrue([@"Republic Square Station" isEqualToString:route801RepublicSquare.name]);
    XCTAssertTrue([@"1" isEqualToString:route1Congress5th.routeId]);
    XCTAssertTrue([@"801" isEqualToString:route801RepublicSquare.routeId]);

    XCTAssertEqual((NSUInteger)1, route1Congress5th.stops.count);
    XCTAssertEqual((NSUInteger)2, route801RepublicSquare.stops.count);

    CAPStop *stop1_1 = route1Congress5th.stops[0];
    CAPStop *stop801_1 = route801RepublicSquare.stops[0];
    CAPStop *stop801_2 = route801RepublicSquare.stops[1];

    NSLog(@"stop801 %@ %@", stop801_1, stop801_2);
    
    XCTAssertTrue([@"581" isEqualToString:stop1_1.stopId]);
    XCTAssertTrue([@"5867" isEqualToString:stop801_1.stopId]);
    XCTAssertTrue([@"5868" isEqualToString:stop801_2.stopId]);
}

- (void)testGTFSDB_CanFindNearbyLocationsForUnidirectionalRoute
{
    GTFSDB *gtfs = [[GTFSDB alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:30.267153 longitude:-97.743061];
    
    NSMutableArray *locations = [gtfs locationsForRoutes:@[@935] nearLocation:loc withinRadius:1.0f];
    
    for (CAPLocation *loc in locations) {
        XCTAssertEqual((NSUInteger)1, loc.stops.count);
    }
}

- (void)testCAPNextBus_CanParseXMLWithRealtimeResponse
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"801-realtime" ofType:@"xml"];
    
    NSError *error = nil;
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) { XCTFail(@"Reading XML failed %@", error); }
   
    CAPNextBus *mockNextBus = [[CAPNextBus alloc] initWithLocation:nil];
    CAPStop *mockStop = [[CAPStop alloc] init];
    [mockNextBus parseXML:xmlString forStop:mockStop];
    
    XCTAssertEqual((NSUInteger)12, mockStop.trips.count);

    CAPTrip *trip1 = mockStop.trips[0];
    CAPTripRealtime *trip1Realtime = trip1.realtime;
    
    XCTAssertTrue([@"801" isEqualToString:trip1.route]);
    XCTAssertTrue([@"11:19 AM" isEqualToString:trip1.tripTime]);
    XCTAssertTrue([@"11:20 AM" isEqualToString:trip1.estimatedTime]);
    XCTAssertTrue(trip1Realtime.valid);
    XCTAssertTrue([@"11:20 AM" isEqualToString:trip1Realtime.estimatedTime]);
    XCTAssertTrue([@"5022" isEqualToString:trip1Realtime.vehicleId]);
}


@end
