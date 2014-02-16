//
//  CAPStop.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAPStop : NSObject

@property NSString *distance;
@property NSString *routeId;
@property NSString *stopId;
@property NSString *tripId;
@property NSString *lat;
@property NSString *lon;
@property NSString *name;
@property NSString *headsign;
@property NSString *desc;


- (void)updateWithGTFS:(NSDictionary *)data;


@end
