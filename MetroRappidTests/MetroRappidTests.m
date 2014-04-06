//
//  MetroRappidTests.m
//  MetroRappidTests
//
//  Created by Luq on 2/23/14.
//  Copyright (c) 2014 Createch. All rights reserved.
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
    while (!gtfs.ready) ;

    CLLocation *loc = [[CLLocation alloc] initWithLatitude:30.267153 longitude:-97.743061];
    
    // FIXME: Add test to support to make sure this can support multiple routes
    NSMutableArray *stops = [gtfs locationsForRoutes:@[@801] nearLocation:loc inDirection:GTFSSouthbound];
    
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

//- (void)testGTFSDB_CanFindNearbyLocationsForUnidirectionalRoute
//{
//    GTFSDB *gtfs = [[GTFSDB alloc] init];
//    CLLocation *loc = [[CLLocation alloc] initWithLatitude:30.267153 longitude:-97.743061];
//    
//    NSMutableArray *locations = [gtfs locationsForRoutes:@[@935] nearLocation:loc inDirection:0];
//    
//    for (CAPLocation *loc in locations) {
//        XCTAssertEqual((NSUInteger)1, loc.stops.count);
//    }
//}
//
//- (void)testCAPNextBus_CanParseXMLWithRealtimeResponse_WithMultipleRuns
//{
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *filePath = [bundle pathForResource:@"801-realtime" ofType:@"xml"];
//    
//    NSError *error = nil;
//    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
//    if (error) { XCTFail(@"Reading XML failed %@", error); }
//    
//    CAPNextBus *mockNextBus = [[CAPNextBus alloc] initWithLocation:nil andRoute:@"801"];
//    CAPStop *mockStop = [[CAPStop alloc] init];
//    [mockNextBus parseXML:xmlString forStop:mockStop];
//    
//    XCTAssertEqual((NSUInteger)12, mockStop.trips.count);
//    
//    CAPTrip *trip1 = mockStop.trips[0];
//    CAPTripRealtime *trip1Realtime = trip1.realtime;
//    
//    XCTAssertTrue([@"801" isEqualToString:trip1.route]);
//    XCTAssertTrue([@"11:19 AM" isEqualToString:trip1.tripTime]);
//    XCTAssertTrue([@"11:20 AM" isEqualToString:trip1.estimatedTime]);
//    XCTAssertTrue(trip1Realtime.valid);
//    XCTAssertTrue([@"11:20 AM" isEqualToString:trip1Realtime.estimatedTime]);
//    XCTAssertTrue([@"5022" isEqualToString:trip1Realtime.vehicleId]);
//}
//
//- (void)testCAPNextBus_CanParseXMLWithRealtimeResponse_WithSingleRun
//{
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *filePath = [bundle pathForResource:@"801-realtime-feb-22" ofType:@"xml"];
//    
//    NSError *error = nil;
//    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
//    if (error) { XCTFail(@"Reading XML failed %@", error); }
//    
//    CAPNextBus *mockNextBus = [[CAPNextBus alloc] initWithLocation:nil andRoute:@"801"];
//    CAPStop *mockStop = [[CAPStop alloc] init];
//    [mockNextBus parseXML:xmlString forStop:mockStop];
//    
//    XCTAssertEqual((NSUInteger)1, mockStop.trips.count);
//    
//    CAPTrip *trip1 = mockStop.trips[0];
//    CAPTripRealtime *trip1Realtime = trip1.realtime;
//    
//    XCTAssertTrue([@"801" isEqualToString:trip1.route]);
//    XCTAssertTrue([@"09:58 PM" isEqualToString:trip1.tripTime]);
//    XCTAssertTrue([@"10:00 PM" isEqualToString:trip1.estimatedTime]);
//    XCTAssertTrue(trip1Realtime.valid);
//    XCTAssertTrue([@"10:00 PM" isEqualToString:trip1Realtime.estimatedTime]);
//    XCTAssertTrue([@"5006" isEqualToString:trip1Realtime.vehicleId]);
//}
//
//- (void)testCAPNextBus_CanParseXMLWithNoArrivals
//{
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *filePath = [bundle pathForResource:@"801-no-arrivals" ofType:@"xml"];
//    
//    NSError *error = nil;
//    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
//    if (error) { XCTFail(@"Reading XML failed %@", error); }
//    
//    CAPNextBus *mockNextBus = [[CAPNextBus alloc] initWithLocation:nil andRoute:@"801"];
//    CAPStop *mockStop = [[CAPStop alloc] init];
//    [mockNextBus parseXML:xmlString forStop:mockStop];
//    
//    XCTAssertEqual((NSUInteger)0, mockStop.trips.count);
//}


@end

