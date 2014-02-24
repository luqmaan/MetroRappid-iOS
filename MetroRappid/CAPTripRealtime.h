//
//  CAPTripRealtime.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAPTripRealtime : NSObject

@property (nonatomic, assign) BOOL valid;
@property NSString *adherence;
@property NSString *estimatedTime;
@property NSString *estimatedMinutes;
@property NSString *polltime;
@property NSString *trend;
@property NSString *speed;
@property NSString *reliable;
@property NSString *stopped;
@property NSString *vehicleId;
@property NSString *lat; // FIXME: Use float
@property NSString *lon; // FIXME: Expose via CLLocation *position;

- (void)updateWithNextBusAPI:(NSDictionary *)data;

@end
