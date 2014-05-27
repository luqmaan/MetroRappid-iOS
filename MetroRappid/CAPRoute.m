//
//  CAPRoute.m
//  MetroRappid
//
//  Created by Luq on 5/17/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRoute.h"
#import "GTFSDB.h"


@interface CAPRoute ()

@end


@implementation CAPRoute

- (id)initWithRouteId:(NSString *)routeId
{
    if (self = [super init]) {
        _routeId = routeId;
        _distance = 0.0f;
    }
    return self;
}

- (void)update
{
    if (!self.gtfsData) {
        self.gtfsData = [GTFSDB routeWithId:self.routeId];
    }

    self.agencyId = self.gtfsData[@"agency_id"];
    self.routeShortName = self.gtfsData[@"route_short_name"];
    self.routeLongName = self.gtfsData[@"route_long_name"];
    self.routeDesc = self.gtfsData[@"route_desc"];
    self.routeType = (GTFSRouteType)[self.gtfsData[@"route_type"] intValue];
    self.routeUrl = self.gtfsData[@"route_url"];
    self.routeColorHex = self.gtfsData[@"route_color"];
    self.routeColor = [[self class] colorFromHexString:self.routeColorHex];
    self.routeTextColorHex = self.gtfsData[@"route_text_color"];
    self.routeTextColor = [[self class] colorFromHexString:self.routeTextColorHex];
    
    if ([self.routeId isEqualToString:@"801"] || [self.routeId isEqualToString:@"550"]) {
        self.routeColor = [UIColor colorWithHue:0.997 saturation:1.000 brightness:0.773 alpha:1];
    }
}

// http://stackoverflow.com/a/12397366/854025
// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
