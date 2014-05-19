//
//  CAPRoute.h
//  MetroRappid
//
//  Created by Luq on 5/17/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property NSString *routeColor;
@property NSString *routeTextColor;

@property (nonatomic, assign) float distance;

- (id)initWithRouteId:(NSString *)routeId;
- (void)update;

@end
