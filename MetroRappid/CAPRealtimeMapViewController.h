//
//  CAPRealtimeMapViewController.h
//  MetroRappid
//
//  Created by Luq on 2/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "CAPNextBus.h"

@interface CAPRealtimeMapViewController : NSObject <MKMapViewDelegate>

- (void)setupMap:(MKMapView *)mapView withStop:(CAPStop *)stop;

@end
