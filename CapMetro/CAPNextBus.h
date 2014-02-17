//
//  CAPNextBus.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CAPStop.h"
#import "CAPTrip.h"

@interface CAPNextBus : NSObject

@property NSMutableArray *trips;
@property CAPLocation *location;
/** The index of the active stop inside of stops */
@property (nonatomic, assign) int activeStopIndex;
@property NSDictionary *nextBusData;
@property NSDate *lastUpdated;
@property (nonatomic, copy) void (^callback)(void);

- (id)initWithLocation:(CAPLocation *)location;
- (id)parseXML:(NSString *)xmlString;
- (void)startUpdates;
- (void)activateNextStop;

@end

