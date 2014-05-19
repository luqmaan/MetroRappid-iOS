//
//  CAPRoutesDataSource.m
//  MetroRappid
//
//  Created by Luq on 5/16/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRoutesDataSource.h"
#import "CAPRoute.h"
#import "GTFSDB.h"
#import "CAPRouteCell.h"

@interface CAPRoutesDataSource ()

/** First array is favorite routes, second is nearby routes. */
@property NSMutableDictionary *routes;

@end


@implementation CAPRoutesDataSource

- (id)init
{
    if (self = [super init]) {
        // FIXME: How will this work with search? New VC/dataSource?
        _routes = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"CAPRoutesDataSource init");
    return self;
}

- (void)loadFavorites
{
    // FIXME: For now, default favorite routes like this. In future save and load to/from preferences.
    CAPRoute *route801 = [[CAPRoute alloc] initWithRouteId:@"801"];
    CAPRoute *route550 = [[CAPRoute alloc] initWithRouteId:@"550"];
    [route801 update];
    [route550 update];
    self.routes[@"favorites"] = @[route801, route550];
}

- (void)loadNearby:(CLLocation *)location
{
    NSMutableArray *nearbyRouteIds = [GTFSDB routesNearLocation:location];
    NSMutableArray *nearbyRoutes = [[NSMutableArray alloc] init];
    
    for (NSString *nearbyRouteId in nearbyRouteIds) {
        CAPRoute *route = [[CAPRoute alloc] initWithRouteId:nearbyRouteId];
        [route update];
        [nearbyRoutes addObject:route];
    }
    
    self.routes[@"nearby"] = nearbyRoutes;
}

#pragma mark - UICollectionViewDataSource

- (NSString*)keyForSection:(NSInteger)section
{
    if (section == 0) {
        return @"favorites";
    }
    if (section == 1) {
        return @"nearby";
    }
    NSLog(@"WTF section %d", (int)section);
    return @"WTF";
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *key = [self keyForSection:section];
    return [self.routes[key] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self keyForSection:indexPath.section];
    CAPRoute *route = self.routes[key][indexPath.row];

    CAPRouteCell *routeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RouteCell" forIndexPath:indexPath];
    
    routeCell.routeIdLabel.text = route.routeId;
    
    return routeCell;
}


@end
