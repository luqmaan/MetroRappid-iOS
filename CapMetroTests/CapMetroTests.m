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

    // FIXME: Add test to support to make sure this can support multiple routes
    NSMutableArray *locations = [gtfs locationsForRoutes:@[@801] nearLocation:loc withinRadius:200.0f];
    
    XCTAssertEqual((NSUInteger)25, locations.count);
    CAPLocation *route801TechRidge = locations[0];
    CAPLocation *route801Chinatown = locations[1];
    CAPLocation *route801RepublicSquare = locations[15];
    CAPLocation *route801SouthParkMeadows = locations[24];

    XCTAssertTrue([@"Tech Ridge Bay I" isEqualToString:route801TechRidge.name]);
    XCTAssertTrue([@"Chinatown Station" isEqualToString:route801Chinatown.name]);
    XCTAssertTrue([@"Republic Square Station" isEqualToString:route801RepublicSquare.name]);
    XCTAssertTrue([@"Southpark Meadows Station" isEqualToString:route801SouthParkMeadows.name]);

    XCTAssertTrue([@"801" isEqualToString:route801RepublicSquare.routeId]);
    XCTAssertTrue([@"801" isEqualToString:route801Chinatown.routeId]);
    XCTAssertTrue([@"801" isEqualToString:route801RepublicSquare.routeId]);
    XCTAssertTrue([@"801" isEqualToString:route801SouthParkMeadows.routeId]);

    XCTAssertEqual((NSUInteger)1, route801TechRidge.stops.count);
    XCTAssertEqual((NSUInteger)2, route801Chinatown.stops.count);
    XCTAssertEqual((NSUInteger)2, route801RepublicSquare.stops.count);
    XCTAssertEqual((NSUInteger)1, route801SouthParkMeadows.stops.count);

    CAPStop *stop801TechRidge_S = route801TechRidge.stops[0];
    CAPStop *stop801Chinatown_S = route801Chinatown.stops[0];
    CAPStop *stop801Chinatown_N = route801Chinatown.stops[1];
    CAPStop *stop801RepublicSquare_S = route801RepublicSquare.stops[0];
    CAPStop *stop801RepublicSquare_N = route801RepublicSquare.stops[1];
    CAPStop *stop801SouthParkMeadows_N = route801SouthParkMeadows.stops[0];
    
    XCTAssertTrue([@"Southbound" isEqualToString:stop801TechRidge_S.headsign]);
    XCTAssertTrue([@"Northbound" isEqualToString:stop801Chinatown_N.headsign]);
    XCTAssertTrue([@"Southbound" isEqualToString:stop801Chinatown_S.headsign]);
    XCTAssertTrue([@"Northbound" isEqualToString:stop801RepublicSquare_N.headsign]);
    XCTAssertTrue([@"Southbound" isEqualToString:stop801RepublicSquare_S.headsign]);
    XCTAssertTrue([@"Southbound" isEqualToString:stop801SouthParkMeadows_N.headsign]);

    NSLog(@"%@ %@", stop801Chinatown_N, stop801Chinatown_S);
    NSLog(@"%@ %@", stop801RepublicSquare_N, stop801RepublicSquare_S);
    
    XCTAssertTrue([@"5304" isEqualToString:stop801TechRidge_S.stopId]);
    XCTAssertTrue([@"4548" isEqualToString:stop801Chinatown_N.stopId]);
    XCTAssertTrue([@"5857" isEqualToString:stop801Chinatown_S.stopId]);
    XCTAssertTrue([@"5868" isEqualToString:stop801RepublicSquare_N.stopId]);
    XCTAssertTrue([@"5867" isEqualToString:stop801RepublicSquare_S.stopId]);
    XCTAssertTrue([@"5873" isEqualToString:stop801SouthParkMeadows_N.stopId]);
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
