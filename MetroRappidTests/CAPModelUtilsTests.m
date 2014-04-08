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

- (void)testDateFromCapMetroTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // expected
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *expected = [formatter dateFromString:@"22/02/2002 11:30 PM"];
    
    // actual
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *reference = [formatter dateFromString:@"22/02/2002"];
    NSDate *actual = [CAPModelUtils dateFromCapMetroTime:@"11:30 PM" withReferenceDate:reference];

    XCTAssertEqual(expected.timeIntervalSince1970, actual.timeIntervalSince1970);
}

- (void)testTimeBetweenStart
{
    NSDate *start = [[NSDate alloc] initWithTimeIntervalSince1970:1396881552.956699];
    NSDate *end = [[NSDate alloc] initWithTimeIntervalSince1970:1396931400.000000];
    
    XCTAssertTrue([@"0m" isEqualToString:[CAPModelUtils timeBetweenStart:start andEnd:start]]);
    XCTAssertTrue([@"13h 50m" isEqualToString:[CAPModelUtils timeBetweenStart:start andEnd:end]]);
}


@end
