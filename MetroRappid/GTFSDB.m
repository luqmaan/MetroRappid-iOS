//
//  GTFS.m
//  CapMetro
//
//  Created by Luq on 2/9/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "GTFSDB.h"

@interface GTFSDB ()

@property FMDatabaseQueue *queue;
@property NSString *databaseName;
@property NSString *databasePath;

@end

@implementation GTFSDB

- (id)init
{
    self = [super init];
    NSLog(@"Init GTFS");
    if (self) {
        self.ready = NO;
        
        self.databaseName = @"gtfs_austin";
        self.databasePath = [[NSBundle mainBundle] pathForResource:self.databaseName ofType:@"db"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, (unsigned long)NULL), ^(void) {
            self.queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
        
            [self addDistanceFunction];
        
            self.ready = YES;
            NSLog(@"Database ready");
        });
    }
    return self;
}

#pragma mark - Setup

- (void)logSchema
{
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *results = [db executeQuery:@"SELECT rootpage, name, sql FROM sqlite_master ORDER BY name;"];
        NSLog(@"tables: %@ %@ %d %@", results, [results resultDictionary], results.columnCount, [results columnNameForIndex:0]);
        for (id column in [results columnNameToIndexMap]) {
            NSLog(@"col: %@", column);
        }
        while ([results next]) {
            NSLog(@"%@ %@ %@", results[1], results[0], results[2]);
        }
    }];
}

// Adds a distance function to the database
// Distance in kilometers
- (void)addDistanceFunction
{
    [self.queue inDatabase:^(FMDatabase *db) {
        // See http://daveaddey.com/?p=71
        [db makeFunctionNamed:@"distance" maximumArguments:4 withBlock:^(sqlite3_context *context, int argc, sqlite3_value **argv) {
            // check that we have four arguments (lat1, lon1, lat2, lon2)
            assert(argc == 4);
            // check that all four arguments are non-null
            if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
                sqlite3_result_null(context);
                return;
            }
            // get the four argument values
            double lat1 = sqlite3_value_double(argv[0]);
            double lon1 = sqlite3_value_double(argv[1]);
            double lat2 = sqlite3_value_double(argv[2]);
            double lon2 = sqlite3_value_double(argv[3]);
            // convert lat1 and lat2 into radians now, to avoid doing it twice below
            double lat1rad = DEG2RAD(lat1);
            double lat2rad = DEG2RAD(lat2);
            // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
            // 6378.1 is the approximate radius of the earth in kilometres
            sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1);
        }];
    }];
}

#pragma mark - Queries

- (NSMutableArray *)locationsForRoutes:(NSArray *)routes nearLocation:(CLLocation *)location inDirection:(GTFSDirection)directionId
{
    NSString *query = [NSString stringWithFormat:
        @"\n SELECT unique_stops.route_id, unique_stops.trip_id, unique_stops.trip_headsign, unique_stops.stop_id, stop_name, "
        @"\n        stop_desc, stop_lat, stop_lon, unique_stops.stop_sequence, unique_stops.direction_id, distance(stop_lat, stop_lon, %f, %f) as \"distance\" "
        @"\n FROM "
        @"\n   stops, "
        @"\n   (SELECT stop_id, route_id, stop_sequence, unique_trips.trip_id, unique_trips.trip_headsign, unique_trips.direction_id "
        @"\n    FROM "
        @"\n      stop_times, "
        @"\n      (SELECT trip_id, route_id, trip_headsign, direction_id "
        @"\n       FROM trips "
        @"\n       WHERE route_id IN (%@) AND direction_id = %d"
        @"\n       GROUP BY shape_id "
        @"\n      ) AS unique_trips "
        @"\n    WHERE stop_times.trip_id = unique_trips.trip_id "
        @"\n    GROUP BY stop_id) AS unique_stops "
        @"\n WHERE stops.stop_id = unique_stops.stop_id "
        @"\n ORDER BY unique_stops.stop_sequence "
        ,
        location.coordinate.latitude,
        location.coordinate.longitude,
        [routes componentsJoinedByString:@", "],
        directionId
    ];
    
    NSMutableArray * __block data = [[NSMutableArray alloc] init];

    [self.queue inDatabase:^(FMDatabase *db) {
        NSLog(@"Executing query %@", query);
        FMResultSet *rs = [db executeQuery:query];

        NSMutableArray *distances = [[NSMutableArray alloc] init];
        while ([rs next]) {
            CAPStop *stop = [[CAPStop alloc] init];
            [stop updateWithGTFS:[rs resultDictionary]];
            [data addObject:stop];
            [distances addObject:[NSNumber numberWithFloat:stop.distance]];
        }
        
        NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        [distances sortUsingDescriptors:@[lowestToHighest]];
        
        for (CAPStop *stop in data) {
            NSUInteger distanceIndex = [distances indexOfObject:[NSNumber numberWithFloat:stop.distance]];
            stop.distanceIndex = (int)distanceIndex;
        }
        
        NSLog(@"GTFS found %d locations with", (int)data.count);
    }];

    return data;
}

- (void)sortStopsByDistance:(NSMutableArray *)stops
{
    [stops sortUsingComparator:^NSComparisonResult(CAPStop* stop1, CAPStop* stop2) {
        if (stop1.distance > stop2.distance) return (NSComparisonResult)NSOrderedDescending;
        else if (stop1.distance < stop2.distance) return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
}


- (void)sortStopsByStopSequence:(NSMutableArray *)stops
{
    [stops sortUsingComparator:^NSComparisonResult(CAPStop* stop1, CAPStop* stop2) {
        
        if (stop1.stopSequence > stop2.stopSequence) return (NSComparisonResult)NSOrderedDescending;
        else if (stop1.stopSequence < stop2.stopSequence) return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
}


@end
