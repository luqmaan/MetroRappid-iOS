//
//  GTFS.m
//  CapMetro
//
//  Created by Luq on 2/9/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "GTFSDB.h"

@implementation GTFSDB

- (id)init
{
    self = [super init];
    NSLog(@"Init GTFS");
    if (self) {
        // Specify the tables names and database names.
        self.tableNames = [[NSMutableArray alloc] initWithObjects:@"route_type",@"calendar",@"calendar_dates",@"feed_info",@"agency",@"transfers",@"patterns",@"stops",@"shapes",@"stop_feature_type",@"fare_attributes",@"universal_calendar",@"routes",@"stop_features",@"fare_rules",@"trips",@"frequencies",@"stop_times", nil];
        self.databaseNames = [NSMutableArray arrayWithArray:@[@"gtfs_austin"]];
        self.documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        static BOOL firstInstanceOfClass = YES;
        if (firstInstanceOfClass) {
            firstInstanceOfClass = NO;
        }
        
        // FIXME: Do the right thing.
        [self deleteAllDatabases];
        [self copyDatabasesFromProjectToDocuments];

        NSString *regionDb = self.databaseNames[0];
        NSString *dbPath = [self.documentsPath stringByAppendingPathComponent:regionDb];
        dbPath = [NSString stringWithFormat:@"%@.db", dbPath];
        self.database = [FMDatabase databaseWithPath:dbPath];
        [self.database open];
        
        [self addDistanceFunction];
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
    FMResultSet *results = [self.database executeQuery:@"SELECT rootpage, name, sql FROM sqlite_master ORDER BY name;"];
    NSLog(@"tables: %@ %@ %d %@", results, [results resultDictionary], results.columnCount, [results columnNameForIndex:0]);
    for (id column in [results columnNameToIndexMap]) {
        NSLog(@"col: %@", column);
    }
    while ([results next]) {
        NSLog(@"%@ %@ %@", results[1], results[0], results[2]);
    }
}

// Adds a distance function to the database
- (void)addDistanceFunction
{
    // See http://daveaddey.com/?p=71
    [self.database makeFunctionNamed:@"distance" maximumArguments:4 withBlock:^(sqlite3_context *context, int argc, sqlite3_value **argv) {
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
}

#pragma mark - Queries

- (NSArray *)routes {
    return nil;
}
- (NSArray *)routesForStop:(NSNumber*)stopNumber {
    return nil;
}

// Find stops nearby the location that are within the given distance.
- (NSArray *)stopsForLocation:(CLLocation *)location andLimit:(int)limit
{
    // Query for nearby stops
    NSString *query = [NSString stringWithFormat:@"SELECT *, distance(stop_lat, stop_lon, %f, %f) as \"distance\" "
                                                  "FROM stops "
                                                  "ORDER BY distance(stop_lat, stop_lon, %f, %f) "
                                                  "LIMIT %d ",
                       location.coordinate.latitude,
                       location.coordinate.longitude,
                       location.coordinate.latitude,
                       location.coordinate.longitude,
                       limit];
    
    NSLog(@"Executing query %@", query);
    FMResultSet *rs = [self.database executeQuery:query];
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        [stops addObject:[rs resultDictionary]];
    }
    
    // Convert to NSArray
    return [stops copy];
}


@end
