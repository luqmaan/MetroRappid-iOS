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
#import "CAPStop.h"

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180


@interface GTFSDB : NSObject

@property NSMutableArray *tableNames;
@property NSMutableArray *databaseNames;
@property NSString *documentsPath;
@property FMDatabase *database;

- (NSArray *)routes;
- (NSArray *)routesForStop:(NSNumber*)stopNumber;
- (NSArray *)stopsForLocation:(CLLocation *)location andLimit:(int)limit;
- (NSMutableArray *)routesForLocation:(CLLocation *)location withLimit:(int)limit;
- (NSMutableArray *)stopsForRoutes:(NSArray *)routes nearLocation:(CLLocation *)location withinRadius:(float)kilometers;
@end
