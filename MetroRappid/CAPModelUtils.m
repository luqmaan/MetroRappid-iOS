//
//  CAPModelUtils.m
//  MetroRappid
//
//  Created by Luq on 4/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPModelUtils.h"

@implementation CAPModelUtils


+ (NSDate *)dateFromCapMetroTime:(NSString *)timeString withReferenceDate:(NSDate *)now;
{
    // The API sends strings without in the format 11:30 AM. To correctly do time comparisons, we need a full date (day, month, year).
    // Take 11:30 AM, add dd/MM/yyyy to the front.
    // Use a dateFormatter to convert this new string into a proper date.

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *estimated = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:now], timeString];

    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *estimatedDate = [formatter dateFromString:estimated];
    
    return estimatedDate;
}

+ (NSString *)timeBetweenStart:(NSDate *)now andEnd:(NSDate *)date;
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:now toDate:date options:0];

    NSString *formattedTimeUntilDate;
    
    if (components.hour > 1) {
        formattedTimeUntilDate = [NSString stringWithFormat:@"%dh %dm", (int)components.hour, (int)components.minute];
    }
    else {
        formattedTimeUntilDate = [NSString stringWithFormat:@"%dm", (int)components.minute];
    }

    return formattedTimeUntilDate;
}


@end
