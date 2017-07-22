//
//  CAPRoutesDataSource.h
//  MetroRappid
//
//  Created by Luq on 5/16/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CAPRoute.h"


@interface CAPRoutesDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, assign) BOOL activityFavorite;
@property (nonatomic, assign) BOOL activityNearby;
@property (nonatomic, assign) BOOL activityAll;

- (void)loadFavoriteRoutes;
- (void)loadAllRoutes;
- (void)loadNearbyRoutes:(CLLocation *)location;
- (void)filterNearbyByDistance:(float)distance;
- (NSInteger)sectionForKey:(NSString *)section;
- (NSString*)keyForSection:(NSInteger)section;
- (NSInteger)numberOfItemsInSectionWithKey:(NSString *)key;
- (CAPRoute *)objectForIndexPath:(NSIndexPath *)indexPath;

@end
