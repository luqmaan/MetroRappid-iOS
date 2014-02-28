//
//  CAPTripRealtime.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CAPTripRealtime : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, assign) BOOL valid;
@property NSString *adherence;
@property NSString *estimatedTime;
@property NSString *estimatedMinutes;
@property NSString *polltime;
@property NSString *trend;
@property NSString *speed;
@property NSString *reliable;
@property NSString *stopped;
@property NSString *vehicleId;
@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lon;

- (void)updateWithNextBusAPI:(NSDictionary *)data;

#pragma mark - MKAnnotation
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property NSString *title;
@property NSString *subtitle;

@end
