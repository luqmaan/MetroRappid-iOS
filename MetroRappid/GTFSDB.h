//
//  GTFS.h
//  CapMetro
//
//  Created by Luq on 2/9/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import <FMDB/FMResultSet.h>
#import <FMDB/FMDatabaseQueue.h>
#import "CAPStop.h"

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180


@interface GTFSDB : NSObject

@property (nonatomic, assign) BOOL ready;

/** 0 = North, 1 = South */
- (NSMutableArray *)locationsForRoutes:(NSArray *)routes nearLocation:(CLLocation *)location inDirection:(int)directionId;

@end
