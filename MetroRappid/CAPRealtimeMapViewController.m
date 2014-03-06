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
    mapView.delegate = self;
    mapView.showsUserLocation = YES;

    for (CAPTrip *trip in stop.trips) {
        CAPTripRealtime *vehicle = trip.realtime;
        
        if (!vehicle.lat || !vehicle.lon) continue;
        
        [mapView addAnnotation:vehicle];
    }
    [self zoomToAnnotationsMapView:mapView];
    NSLog(@"Did setup mapview with %d annotations", (int)mapView.annotations.count);
}

- (void)updateMap:(MKMapView *)mapView withStop:(CAPStop *)stop
{
    NSMutableArray *existing = [[NSMutableArray alloc] init];
    for (id annotation in mapView.annotations) {
        if ([annotation class] == [CAPTripRealtime class]) {
            [existing addObject:annotation];
        }
    }
    NSLog(@"Found %d existing annotations", (int)existing.count);
    
    for (CAPTrip *trip in stop.trips) {
        CAPTripRealtime *vehicle = trip.realtime;
        if (!vehicle.lat || !vehicle.lon) continue;
 
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"vehicleId == '%@'", vehicle.vehicleId]];
        NSArray *matches = [existing filteredArrayUsingPredicate:predicate];
        if (matches.count > 0) {
            CAPTripRealtime *match = matches[0];
            [UIView animateWithDuration:2.0f animations:^{
                match.coordinate = vehicle.coordinate;
            }];
            if (matches.count > 1) NSLog(@"Wtf too many matching vehicles %@ for vehicle %@", matches, vehicle);
            [existing removeObject:match];
        }
        else {
            [mapView addAnnotation:vehicle];
        }
        [existing removeObject:vehicle];
    }
    NSLog(@"%d expired annotations will be removed", (int)existing.count);
    for (id expiredAnnotation in existing) {
        [mapView removeAnnotation:expiredAnnotation];
    }
    [mapView deselectAnnotation:mapView.annotations[0] animated:YES];
    [mapView selectAnnotation:mapView.annotations[0] animated:YES];
    self.foundUserLocation = NO;
    [self zoomToAnnotationsMapView:mapView];
    NSLog(@"Did setup mapview with %d annotations", (int)mapView.annotations.count);
}

- (void)zoomToAnnotationsMapView:(MKMapView *)mapView
{
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:mapView.annotations];
    
    if (!self.foundUserLocation && mapView.userLocation.location.horizontalAccuracy > kCLLocationAccuracyKilometer) {
        NSLog(@"Accurate location found, ignoring future updates");
        [annotations addObject:mapView.userLocation];
        self.foundUserLocation = YES;
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
    [self zoomToAnnotationsMapView:mapView];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

@end
