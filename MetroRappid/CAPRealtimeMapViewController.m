//
//  CAPRealtimeMapViewController.m
//  MetroRappid
//
//  Created by Luq on 2/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRealtimeMapViewController.h"

@interface CAPRealtimeMapViewController ()

@property BOOL foundUserLocation;

@end

@implementation CAPRealtimeMapViewController

- (void)setupMap:(MKMapView *)mapView withStop:(CAPStop *)stop
{
    NSLog(@"Setup mapview %@ with nextBus %@", mapView, stop);
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeFollow;

    for (CAPTrip *trip in stop.trips) {
        CAPTripRealtime *vehicle = trip.realtime;
        
        if (!vehicle.lat || !vehicle.lon) continue;
        
        [mapView addAnnotation:vehicle];
    }
    [self zoomToAnnotationsMapView:mapView];
    NSLog(@"Did setup mapview with %d annotations", (int)mapView.annotations.count);
}

- (void)zoomToAnnotationsMapView:(MKMapView *)mapView
{
    NSLog(@"zoomToAnnotationsMapView");
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:mapView.annotations];

    // FIXME: See how this works IRL
    if (!self.foundUserLocation && mapView.userLocation.location.horizontalAccuracy > kCLLocationAccuracyHundredMeters) {
        NSLog(@"Accurate location found, ignoring future updates");
        [annotations addObject:mapView.userLocation];
        self.foundUserLocation = YES;
        mapView.userTrackingMode = MKUserTrackingModeNone;
    }
    
    [mapView showAnnotations:annotations animated:YES];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)newUserLocation
{
    NSLog(@"mapView didUpdateUserLocation");
    [self zoomToAnnotationsMapView:mapView];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

@end
