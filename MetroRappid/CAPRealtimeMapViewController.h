//
//  CAPRealtimeMapViewController.h
//  MetroRappid
//
//  Created by Luq on 2/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "CAPStop.h"

@interface CAPRealtimeMapViewController : NSObject <MKMapViewDelegate>

- (id)initWithWithMapView:(MKMapView *)mapView forLocation:(CAPLocation *)location;

@end
