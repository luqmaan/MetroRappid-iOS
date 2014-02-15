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
@property id stop;
@property NSString* stopId;
@property NSDictionary *nextBusData;

- (id)initWithStop:(NSString *)stopId;
- (id)parseXML:(NSString *)xmlString;

@end

