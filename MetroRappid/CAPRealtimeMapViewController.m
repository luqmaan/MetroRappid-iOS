//
//  CAPRealtimeMapViewController.m
//  MetroRappid
//
//  Created by Luq on 2/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRealtimeMapViewController.h"
#import "CAPTripRealtimeView.h"

@interface CAPRealtimeMapViewController ()

@property BOOL foundUserLocation;

@end

@implementation CAPRealtimeMapViewController

- (void)setupMap:(MKMapView *)mapView withStop:stop
{
    NSLog(@"Setup mapview %@", mapView);
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    mapView.userInteractionEnabled = YES;
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotation:stop];
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
        if (!vehicle.lat || !vehicle.lon) {
            NSLog(@"Skipping vehicle %@ %@", vehicle, vehicle._data);
            continue;
        };

        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"vehicleId == '%@'", vehicle.vehicleId]];
        NSArray *matches = [existing filteredArrayUsingPredicate:predicate];
        if (matches.count > 0) {
            CAPTripRealtime *match = matches[0];
            [match updateWithNextBusAPI:vehicle._data];
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

    NSLog(@"%d expired vehicles will be removed", (int)existing.count);
    for (id expiredVehicle in existing) {
        [mapView removeAnnotation:expiredVehicle];
    }
    CAPTripRealtime *closestTrip = nil;
    for (id annotation in mapView.annotations) {
        if ([annotation class] == [CAPTripRealtime class]) {
            CAPTripRealtime *trip = (CAPTripRealtime *)annotation;
            if (!closestTrip) closestTrip = trip;
            if ([closestTrip.estimatedMinutes intValue] > [trip.estimatedMinutes intValue]) closestTrip = trip;
        }
    }
    if (closestTrip) {
        NSLog(@"Selecting closestTrip %@", closestTrip);
        [mapView deselectAnnotation:closestTrip animated:YES];
        [mapView selectAnnotation:closestTrip animated:YES];
    }

    [self zoomToAnnotationsMapView:mapView];
    NSLog(@"Did update mapView to have %d annotations", (int)mapView.annotations.count);
}

- (void)zoomToAnnotationsMapView:(MKMapView *)mapView
{
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:mapView.annotations];

    if (mapView.userLocation.location.horizontalAccuracy > kCLLocationAccuracyThreeKilometers) {
        NSLog(@"Accurate location found %@", mapView.userLocation);
        [annotations addObject:mapView.userLocation];
    }

    [mapView showAnnotations:annotations animated:YES];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CAPTripRealtime class]]) {
        CAPTripRealtime *stop = (CAPTripRealtime *)annotation;
        NSString *tripAnnotationID = [NSString stringWithFormat:@"CAPTripRealtime"];

        MKAnnotationView *tripView = [theMapView dequeueReusableAnnotationViewWithIdentifier:tripAnnotationID];
        if (tripView) {
            tripView.annotation = stop;
        }
        else {
            tripView = [[CAPTripRealtimeView alloc] initWithAnnotation:annotation reuseIdentifier:tripAnnotationID];
            tripView.tintColor = [UIColor greenColor];
            tripView.canShowCallout = YES;
        }
        return tripView;
    }
    return nil;
}

/*
 - (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
}
*/

/*
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
}
*/

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    CAPTripRealtime *trip = (CAPTripRealtime *)view.annotation;
    NSLog(@"Did select %@ ", trip);
}

/*
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
}
*/

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)newUserLocation
{
    if (!self.foundUserLocation) [self zoomToAnnotationsMapView:mapView];
    self.foundUserLocation = YES;
}

/*
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}
*/

@end
