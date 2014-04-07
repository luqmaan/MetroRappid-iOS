//
//  CAPModelUtilsTests.m
//  MetroRappid
//
//  Created by Luq on 4/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CAPModelUtils.h"

@interface CAPModelUtilsTests : XCTestCase

@end

@implementation CAPModelUtilsTests

- (NSDate *)mockDateMethod
{
    XCTAssertTrue(YES == YES);
}

- (void)testDateFromCapMetroTimeString
{
    NSDate *reference = [[NSDate alloc] initWithTimeIntervalSince1970:1396881552.956699];
    NSDate *date1 = [CAPModelUtils dateFromCapMetroTime:@"11:30 PM" withReferenceDate:reference];
    XCTAssertEqual(1396931400.000000, date1.timeIntervalSince1970);
}

- (void)testTimeBetweenStart
{
    NSDate *start = [[NSDate alloc] initWithTimeIntervalSince1970:1396881552.956699];
    NSDate *end = [[NSDate alloc] initWithTimeIntervalSince1970:1396931400.000000];
    
    XCTAssertTrue([@"0m" isEqualToString:[CAPModelUtils timeBetweenStart:start andEnd:start]]);
    XCTAssertTrue([@"13h 50m" isEqualToString:[CAPModelUtils timeBetweenStart:start andEnd:end]]);
}


@end
