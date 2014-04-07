//
//  MetroRappidTests.m
//  MetroRappidTests
//
//  Created by Luq on 2/23/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XMLDictionary/XMLDictionary.h>
#import "CAPNextBus.h"
#import "CAPTrip.h"
#import "CAPTripRealtime.h"
#import "CAPStop.h"

@interface CAPNextBusTests : XCTestCase

@end

@implementation CAPNextBusTests

- (void)testCanParseXMLWithRealtimeResponse_WithMultipleRuns
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"801-realtime" ofType:@"xml"];
    
    NSError *error = nil;
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) { XCTFail(@"Reading XML failed %@", error); }
    
    CAPNextBus *nextBus = [[CAPNextBus alloc] init];
    CAPStop *mockStop = [[CAPStop alloc] init];
    
    void (^errorCallback)(NSError *error) = ^void(NSError *error) {
        XCTFail(@"onError should not be called %@", error);
    };

    void (^completedCallback)() = ^void(){
        XCTAssertEqual((NSUInteger)12, mockStop.trips.count);
        
        CAPTrip *trip1 = mockStop.trips[0];
        CAPTripRealtime *trip1Realtime = trip1.realtime;

        NSLog(@"trip1.estimatedTime %@", trip1.estimatedTime);
        NSLog(@"trip1Realtime.estimatedTime %@", trip1Realtime.estimatedTime);
        
        XCTAssertTrue([@"801" isEqualToString:trip1.route]);
        XCTAssertTrue([@"11:19 AM" isEqualToString:trip1.tripTime]);
        XCTAssertTrue(trip1Realtime.valid);
        XCTAssertTrue([@"5022" isEqualToString:trip1Realtime.vehicleId]);
    };

    [nextBus updateStop:mockStop withXML:xmlString onCompleted:completedCallback onError:errorCallback];
}

- (void)testCanParseXMLWithRealtimeResponse_WithSingleRun
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"801-realtime-feb-22" ofType:@"xml"];
    
    NSError *error = nil;
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) { XCTFail(@"Reading XML failed %@", error); }
    
    CAPNextBus *nextBus = [[CAPNextBus alloc] init];
    CAPStop *mockStop = [[CAPStop alloc] init];

    void (^errorCallback)(NSError *error) = ^void(NSError *error) {
        XCTFail(@"onError should not be called %@", error);
    };
    
    void (^completedCallback)() = ^void(){
        XCTAssertEqual((NSUInteger)1, mockStop.trips.count);
        
        CAPTrip *trip1 = mockStop.trips[0];
        CAPTripRealtime *trip1Realtime = trip1.realtime;
        
        XCTAssertTrue([@"801" isEqualToString:trip1.route]);
        XCTAssertTrue([@"09:58 PM" isEqualToString:trip1.tripTime]);
        XCTAssertTrue(trip1Realtime.valid);
        XCTAssertTrue([@"5006" isEqualToString:trip1Realtime.vehicleId]);
    };
    
    [nextBus updateStop:mockStop withXML:xmlString onCompleted:completedCallback onError:errorCallback];
}

- (void)testCanParseXMLWithNoArrivals
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"801-no-arrivals" ofType:@"xml"];
    
    NSError *error = nil;
    NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) { XCTFail(@"Reading XML failed %@", error); }
    
    CAPNextBus *nextBus = [[CAPNextBus alloc] init];
    CAPStop *mockStop = [[CAPStop alloc] init];

    void (^errorCallback)(NSError *error) = ^void(NSError *error) {
        XCTAssertEqual((NSUInteger)0, mockStop.trips.count);
    };
    
    void (^completedCallback)() = ^void() {
        XCTFail(@"onCompleted should not be called");
    };

    [nextBus updateStop:mockStop withXML:xmlString onCompleted:completedCallback onError:errorCallback];
}


@end

