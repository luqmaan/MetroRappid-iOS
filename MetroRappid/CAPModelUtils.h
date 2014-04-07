//
//  CAPModelUtils.h
//  MetroRappid
//
//  Created by Luq on 4/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAPModelUtils : NSObject

+ (NSDate *)dateFromCapMetroTime:(NSString *)timeString withReferenceDate:(NSDate *)now;
+ (NSString *)timeBetweenStart:(NSDate *)now andEnd:(NSDate *)date;

@end
