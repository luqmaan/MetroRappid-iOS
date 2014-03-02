//
//  CAPRealtimeMapViewController.m
//  MetroRappid
//
//  Created by Luq on 2/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRealtimeMapViewController.h"

@interface CAPRealtimeMapViewController ()

@end

@implementation CAPRealtimeMapViewController

//- (id)initWithNextBus:(CAPNextBus *)nextBus
//{
//    self = [super init];
//    if (self) {
//        NSLog(@"Init mapview");
//        self.nextBus = nextBus;
//    }
//    return self;
//}

- (void)setupMap:(MKMapView *)mapView withNextBus:(CAPNextBus *)nextBus
{
    NSLog(@"Setup mapview %@ with nextBus %@ %@", mapView, nextBus, nextBus.location);
    mapView.showsUserLocation = YES;

    CAPStop *activeStop = nextBus.location.stops[ nextBus.activeStopIndex];
    for (CAPTrip *trip in activeStop.trips) {
        CAPTripRealtime *vehicle = trip.realtime;
        
        if (!vehicle.lat || !vehicle.lon) continue;
        
        [mapView addAnnotation:vehicle];
    }
    [self zoomToAnnotationsMapView:mapView];
    NSLog(@"Did setup mapview with %d annotations", (int)mapView.annotations.count);
}

- (void)zoomToAnnotationsMapView:(MKMapView *)mapView
{
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:mapView.annotations];
    [annotations addObject:mapView.userLocation];
    [mapView showAnnotations:mapView.annotations animated:YES];
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

- (void)mapView:(MKMapView *)map didUpdateUserLocation:(MKUserLocation *)newUserLocation
{
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

@end
