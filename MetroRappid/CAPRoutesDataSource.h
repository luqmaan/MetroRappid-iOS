//
//  CAPRoutesDataSource.h
//  MetroRappid
//
//  Created by Luq on 5/16/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface CAPRoutesDataSource : NSObject <UICollectionViewDataSource>

- (void)loadFavorites;
- (void)loadNearby:(CLLocation *)location;

@end
