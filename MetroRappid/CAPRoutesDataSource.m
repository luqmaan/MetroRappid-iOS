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
#import "CAPRouteHeaderView.h"

@interface CAPRoutesDataSource ()

/** First array is favorite routes, second is nearby routes. */
@property NSMutableDictionary *routes;
@property NSMutableArray *allRoutes;

@end


@implementation CAPRoutesDataSource

- (id)init
{
    if (self = [super init]) {
        // FIXME: How will this work with search? New VC/dataSource?
        _routes = [[NSMutableDictionary alloc] init];
        _allRoutes = [[NSMutableArray alloc] init];
        _activityFavorite = YES;
        _activityNearby = YES;
        _activityAll = YES;
    }
    NSLog(@"CAPRoutesDataSource init");
    return self;
}

- (void)loadFavoriteRoutes
{
    // FIXME: For now, default favorite routes like this. In future save and load to/from preferences.
    CAPRoute *route801 = [[CAPRoute alloc] initWithRouteId:@"801"];
    CAPRoute *route550 = [[CAPRoute alloc] initWithRouteId:@"550"];
    [route801 update];
    [route550 update];
    self.routes[@"favorites"] = @[route801, route550];
    self.activityFavorite = NO;
}

- (void)loadAllRoutes
{
    NSMutableArray *allRouteIds = [GTFSDB routes];
    
    for (NSDictionary *nearbyRouteData in allRouteIds) {
        CAPRoute *route = [[CAPRoute alloc] initWithRouteId:nearbyRouteData[@"route_id"]];
        [route update];
        [self.allRoutes addObject:route];
    }
    self.routes[@"all"] = self.allRoutes;
    self.activityAll = NO;
}

- (void)loadNearbyRoutes:(CLLocation *)location
{
    NSMutableArray *nearbyRouteIds = [GTFSDB routesNearLocation:location];
    NSMutableArray *nearbyRoutes = [[NSMutableArray alloc] init];
    
    for (NSDictionary *nearbyRouteData in nearbyRouteIds) {
        CAPRoute *route = [[CAPRoute alloc] initWithRouteId:nearbyRouteData[@"route_id"]];
        route.distance = [nearbyRouteData[@"ledistance"] floatValue];
        [route update];
        [nearbyRoutes addObject:route];
    }
    
    self.allRoutes = [nearbyRoutes mutableCopy];

    self.routes[@"nearby"] = nearbyRoutes;
    self.activityNearby = NO;
    [self filterNearbyByDistance:4.0];
}

- (void)filterNearbyByDistance:(float)distance
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"distance < %f", distance]];
    NSArray *filteredRoutes = [self.allRoutes filteredArrayUsingPredicate:predicate];
    NSLog(@"Filtered %d nearby routes", (int)filteredRoutes.count);
    NSSortDescriptor *distanceSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    filteredRoutes = [filteredRoutes sortedArrayUsingDescriptors:@[distanceSortDescriptor]];
    self.routes[@"nearby"] = filteredRoutes;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)sectionForKey:(NSString *)section
{
    if ([section isEqualToString:@"favorites"]) {
        return 0;
    }
    if ([section isEqualToString:@"nearby"]) {
        return 1;
    }
    if ([section isEqualToString:@"all"]) {
        return 2;
    }
    return 666;
}

- (NSString*)keyForSection:(NSInteger)section
{
    if (section == 0) {
        return @"favorites";
    }
    if (section == 1) {
        return @"nearby";
    }
    if (section == 2) {
        return @"all";
    }

    NSLog(@"WTF section %d", (int)section);
    return @"WTF";
}

- (NSInteger)numberOfItemsInSectionWithKey:(NSString *)key
{
    return [self.routes[key] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *key = [self keyForSection:section];
    return [self.routes[key] count];
}

#pragma mark - Cell

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self keyForSection:indexPath.section];
    CAPRoute *route = self.routes[key][indexPath.row];

    CAPRouteCell *routeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RouteCell" forIndexPath:indexPath];
    
    routeCell.routeIdLabel.text = route.routeId;
    [routeCell setRouteName:route.routeLongName];
    [routeCell setColor:route.routeColor textColor:route.routeTextColor];
    
    if (routeCell.selected) {
        [routeCell appearSelected];
    }
    else {
        [routeCell appearDeselected];
    }
    
    return routeCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CAPRouteCell *cell = (CAPRouteCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell appearSelected];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CAPRouteCell *cell = (CAPRouteCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell appearDeselected];
}

#pragma mark - Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CAPRouteHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RouteHeader" forIndexPath:indexPath];
    
    NSString *section = [self keyForSection:indexPath.section];
    NSLog(@"Section indexPath %@ %@", section, indexPath);

    if ([section isEqualToString:@"favorites"]) {
        headerView.sectionLabel.text = @"REALTIME";
        if (!self.activityFavorite) {
            [headerView.activityIndicator stopAnimating];
        }
    }
    if ([section isEqualToString:@"nearby"]) {
        headerView.sectionLabel.text = @"NEARBY";
        if (!self.activityNearby) {
            [headerView.activityIndicator stopAnimating];
        }
    }
    if ([section isEqualToString:@"all"]) {
        headerView.sectionLabel.text = @"ALL";
        if (!self.activityAll) {
            [headerView.activityIndicator stopAnimating];
        }
    }
    
    return headerView;
}

@end
