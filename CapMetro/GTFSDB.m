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
@property NSMutableArray *databaseNames;
@property NSString *documentsPath;
@property NSString *databasePath;

@end

@implementation GTFSDB

- (id)init
{
    self = [super init];
    NSLog(@"Init GTFS");
    if (self) {
        // Specify the tables names and database names.
        self.databaseNames = [NSMutableArray arrayWithArray:@[@"gtfs_austin"]];

        self.documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *regionDb = self.databaseNames[0];
        NSString *dbPath = [self.documentsPath stringByAppendingPathComponent:regionDb];
        self.databasePath = [NSString stringWithFormat:@"%@.db", dbPath];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    
        // FIXME: Do the right thing. Only install db when needed. Then call setup started callback.
        [self deleteAllDatabases];
        [self copyDatabasesFromProjectToDocuments];

        [self addDistanceFunction];
        NSLog(@"Database ready");
    }
    return self;
}

#pragma mark - Setup

- (void)deleteAllDatabases {
    for (NSString *databaseName in self.databaseNames) {
        NSLog(@"DELETE %@", databaseName);
        // The destination path of the database
        NSString *dbPath = [self.documentsPath stringByAppendingPathComponent:databaseName];
        dbPath = [NSString stringWithFormat:@"%@.db", dbPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:dbPath error:&error];
        if (error) {
            NSLog(@"Error removing database at path %@ : %@", dbPath, error);
        }
    }
}

// Add the databases to the Documents directory.
// It isn't necessary to check if every cities data is up to date; the user only cares about their own city.
- (void)copyDatabasesFromProjectToDocuments
{
    NSLog(@"Copying databases from project to documents, if needed.");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *databaseName in self.databaseNames) {
        // The destination path of the database
        NSString *dbPath = [self.documentsPath stringByAppendingPathComponent:databaseName];
        dbPath = [NSString stringWithFormat:@"%@.db", dbPath];
        
        // Check if the db already exists in the Documents folder
        if (![fileManager fileExistsAtPath:dbPath]) {
            NSLog(@"Database not already present. Copying %@ from project folder to document's directory.", databaseName);
            // Copy the db from the Project directory to the Documents directory
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:databaseName ofType:@"db"];
            NSError *error;
            [fileManager copyItemAtPath:sourcePath toPath:dbPath error:&error];
            if (error) {
                NSLog(@"Error copy file from project directory to documents directory: %@", error);
            }
        }
        else {
            NSLog(@"The database %@ already exists in the Documents directory.", databaseName);
        }
    }
}

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

- (NSArray *)routes {
    return nil;
}
- (NSArray *)routesForStop:(NSNumber*)stopNumber {
    return nil;
}

- (NSMutableArray *)locationsForRoutes:(NSArray *)routes nearLocation:(CLLocation *)location withinRadius:(float)kilometers
{
    NSString *query = [NSString stringWithFormat:
        @"\n SELECT unique_stops.route_id, unique_stops.trip_id, unique_stops.trip_headsign, unique_stops.stop_id, stop_name, "
        @"\n        stop_desc, stop_lat, stop_lon, unique_stops.stop_sequence, distance(stop_lat, stop_lon, %f, %f) as \"distance\" "
        @"\n FROM "
        @"\n   stops, "
        @"\n   (SELECT stop_id, route_id, stop_sequence, unique_trips.trip_id, unique_trips.trip_headsign "
        @"\n    FROM "
        @"\n      stop_times, "
        @"\n      (SELECT trip_id, route_id, trip_headsign "
        @"\n       FROM trips "
        @"\n       WHERE route_id IN (%@) "
        @"\n       GROUP BY shape_id "
        @"\n      ) AS unique_trips "
        @"\n    WHERE stop_times.trip_id = unique_trips.trip_id "
        @"\n    GROUP BY stop_id) AS unique_stops "
        @"\n WHERE stops.stop_id = unique_stops.stop_id "
        @"\n AND distance(stop_lat, stop_lon, %f, %f) < %f ",
        location.coordinate.latitude,
        location.coordinate.longitude,
        [routes componentsJoinedByString:@", "],
        location.coordinate.latitude,
        location.coordinate.longitude,
        kilometers
    ];

    NSMutableArray * __block data;

    [self.queue inDatabase:^(FMDatabase *db) {
        NSLog(@"Executed query %@", query);
        FMResultSet *rs = [db executeQuery:query];

        // FIXME: There has to be a better way to determine if two stops are related.
        //        Currently use if same route id and same stop name, they are related.
        NSMutableDictionary *stopsDictWithLocationAsKey = [[NSMutableDictionary alloc] init];
        
        while ([rs next]) {
            CAPStop *stop = [[CAPStop alloc] init];
            [stop updateWithGTFS:[rs resultDictionary]];
            
            // Combine stops with the same name, but different directions
            NSString *key = [NSString stringWithFormat:@"%@ %@", stop.name, stop.routeId];
            
            if (!stopsDictWithLocationAsKey[key]) {
                stopsDictWithLocationAsKey[key] = [[CAPLocation alloc] init];
            }
            CAPLocation *location = stopsDictWithLocationAsKey[key];
            
            [location updateWithStop:stop];
        }
        
        data = [NSMutableArray arrayWithArray:[stopsDictWithLocationAsKey allValues]];
        
        [self sortStopsByDirectionForLocations:data];
        
        // Add an indicator of closeness to the location
        [self sortLocationsByDistance:data];
        int distanceIndex = 0;
        for (CAPLocation *location in data) {
            location.distanceIndex = distanceIndex;
            distanceIndex++;
        }
        
        // Sort by stopSequence, North to South
        [self sortLocationsByStopSequence:data];
        NSLog(@"GTFS found %d locations with", (int)data.count);
    }];

    return data;
}

- (void)sortStopsByDirectionForLocations:(NSMutableArray *)locations
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"directionId" ascending:NO];
    for (CAPLocation *location in locations) {
        [location.stops sortUsingDescriptors:@[sortDescriptor]];
    }
}

- (void)sortLocationsByDistance:(NSMutableArray *)locations
{
    [locations sortUsingComparator:^NSComparisonResult(CAPLocation* location1, CAPLocation* location2) {
        if (location1.distance > location2.distance) return (NSComparisonResult)NSOrderedDescending;
        else if (location1.distance < location2.distance) return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
}

- (void)sortLocationsByStopSequence:(NSMutableArray *)locations
{
    // Make sure to call sortStopsByDirectionForLocations:(NSMutableArray *)locations first
    [locations sortUsingComparator:^NSComparisonResult(CAPLocation* location1, CAPLocation* location2) {
        CAPStop *stop1 = location1.stops[0];
        CAPStop *stop2 = location2.stops[0];
        
        if (stop1.stopSequence > stop2.stopSequence) return (NSComparisonResult)NSOrderedDescending;
        else if (stop1.stopSequence < stop2.stopSequence) return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
}

@end
