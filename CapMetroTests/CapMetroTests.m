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

- (void)testFindNearbyStopsForRoute
{
    GTFSDB *gtfs = [[GTFSDB alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:30.267153 longitude:-97.743061];

    NSMutableArray *stops = [gtfs stopsForRoutes:@[@801, @1] nearLocation:loc withinRadius:2.0f];
    NSLog(@"stops %@", stops);
    
    XCTAssertEqual((NSUInteger)38, stops.count);
    CAPStop *routet1CongressStop = stops[0];
    CAPStop *route801WooldrigeStop = stops[2];

    XCTAssertTrue([@"200 CONGRESS/2ND" isEqualToString:routet1CongressStop.name]);
    XCTAssertTrue([@"WOOLDRIDGE SQUARE STATION (NB)" isEqualToString:route801WooldrigeStop.name]);
    XCTAssertTrue([@"1" isEqualToString:routet1CongressStop.routeId]);
    XCTAssertTrue([@"801" isEqualToString:route801WooldrigeStop.routeId]);
}

- (void)testCAPNextBusParseXMLWithRealtimeResponse
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"801-realtime" ofType:@"xml"];
    
    NSError *error = nil;
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) { XCTFail(@"Reading XML failed %@", error); }
   
    CAPNextBus *nextBus = [[CAPNextBus alloc] initWithStop:nil];
    [nextBus parseXML:xmlString];
    
    XCTAssertEqual((NSUInteger)12, nextBus.trips.count);

    CAPTrip *trip1 = nextBus.trips[0];
    CAPTripRealtime *trip1Realtime = trip1.realtime;
    
    XCTAssertTrue([@"801" isEqualToString:trip1.route]);
    XCTAssertTrue([@"11:19 AM" isEqualToString:trip1.tripTime]);
    XCTAssertTrue([@"11:20 AM" isEqualToString:trip1.estimatedTime]);
    XCTAssertTrue([@"Y" isEqualToString:trip1Realtime.valid]);
    XCTAssertTrue([@"11:20 AM" isEqualToString:trip1Realtime.estimatedTime]);
    XCTAssertTrue([@"5022" isEqualToString:trip1Realtime.vehicleId]);
}


@end
