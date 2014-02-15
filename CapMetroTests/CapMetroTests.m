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

- (void)testFindNearbyStopsAndTrips
{
    // TODO
}

- (void)testCAPNextBusCanCreateTripsWithRealtimeXML
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"801-realtime" ofType:@"xml"];
    
    NSError *error = nil;
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) { XCTFail(@"Reading XML failed %@", error); }
   
    CAPNextBus *nextBus = [[CAPNextBus alloc] initWithStop:@"123"];
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
