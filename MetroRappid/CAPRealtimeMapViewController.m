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
    NSLog(@"Setup mapview");
    mapView.showsUserLocation = YES;

    CAPStop *activeStop = nextBus.location.stops[ nextBus.activeStopIndex];
    for (CAPTrip *trip in activeStop.trips) {
        CAPTripRealtime *vehicle = trip.realtime;
        NSLog(@"add annotation %@", vehicle);
        [mapView addAnnotation:vehicle];
        NSLog(@"Did add annotation");
    }
    [self zoomToAnnotationsMapView:mapView];
    NSLog(@"Did setup mapview");
}

- (void)zoomToAnnotationsMapView:(MKMapView *)mapView
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(0, 10, 15, 10) animated:YES];
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
