//
//  CAPRoute.h
//  MetroRappid
//
//  Created by Luq on 5/17/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    GTFSRouteTypeTramStreetcarLightRail,
    GTFSRouteTypeSubwayMetro,
    GTFSRouteTypeRail,
    GTFSRouteTypeBus,
    GTFSRouteTypeFerry,
    GTFSRouteTypeCableCar,
    GTFSRouteTypeGondola,
    GTFSRouteTypeFunicular
} GTFSRouteType;


@interface CAPRoute : NSObject

@property NSDictionary *gtfsData;

@property NSString *routeId;
@property NSString *agencyId;
@property NSString *routeShortName;
@property NSString *routeLongName;
@property NSString *routeDesc;
@property GTFSRouteType routeType;
@property NSString *routeUrl;
@property UIColor *routeColor;
@property NSString *routeColorHex;
@property UIColor *routeTextColor;
@property NSString *routeTextColorHex;

@property (nonatomic, assign) float distance;

@property NSMutableArray *trips;

- (id)initWithRouteId:(NSString *)routeId;
- (void)update;

@end
