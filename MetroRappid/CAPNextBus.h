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

@property NSString *routeId;
@property CAPLocation *location;
/** The index of the active stop inside of stops */
@property (nonatomic, assign) int activeStopIndex;
@property NSDictionary *nextBusData;
@property (nonatomic, copy) void (^completedCallback)(void);
@property (nonatomic, copy) void (^errorCallback)(NSError*);
@property (nonatomic, copy) void (^progressCallback)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

- (id)initWithLocation:(CAPLocation *)location andRoute:(NSString *)routeId;
- (id)parseXML:(NSString *)xmlString forStop:(CAPStop *)stop;
- (void)startUpdates;
- (void)activateNextStop;

@end

