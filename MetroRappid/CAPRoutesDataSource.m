//
//  CAPRoutesDataSource.m
//  MetroRappid
//
//  Created by Luq on 5/16/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRoutesDataSource.h"
#import "GTFSDB.h"


@interface CAPRoutesDataSource()

@property NSMutableArray *routes;

@end


@implementation CAPRoutesDataSource

@synthesize routes;

- (id)init
{
    self = [super init];
    if (self) {
        GTFSDB *gtfsdb = nil;
        
        // FIXME: For now, default favorite routes like this. In future save and load to/from preferences.
        CAPRoute *route801 = [[CAPRoute alloc] initWithGTFS:[gtfsb route:801]];
        CAPRoute *route550 = [[CAPRoute alloc] initWithGTFS:[gtfsb route:550]];

        // FIXME: How will this work with search? New VC/datasource?
        // First array is favorites/realtime. Second is nearby.
        self.routes = [[NSMutableArray alloc] initWithArray:@[ @[route801, route550] ]];

        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.distanceFilter = 100; // meters
        [locationManager startUpdatingLocation];
    }
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)locationManager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"Got location %@", lastLocation);
    
    if (lastLocation.horizontalAccuracy > kCLLocationAccuracyHundredMeters) {
        [locationManager stopUpdatingLocation];
        
        NSMutableArray *nearbyRoutes = [[NSMutableArray alloc] init];
        NSMutableArray *nearbyRoutesData = [gtfsdb routesNearLocation:lastLocation];

        for (NSDictionary *routeData in nearbyRoutesData) {
            CAPRoute *route = [[CAPRoute alloc] initWithGTFS:routeData];
            [nearbyRoutes addObject:route];
        }
        
        [self.routes addObject:nearbyRoutes];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.routes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.routes[indexPath.row] count];
}


@end
