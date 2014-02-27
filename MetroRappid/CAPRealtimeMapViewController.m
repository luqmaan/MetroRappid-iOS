//
//  CAPRealtimeMapViewController.m
//  MetroRappid
//
//  Created by Luq on 2/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRealtimeMapViewController.h"

@interface CAPRealtimeMapViewController ()

@property MKMapView *mapView;

@end

@implementation CAPRealtimeMapViewController

- (id)initWithWithMapView:(MKMapView *)mapView forLocation:(CAPLocation *)location
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
    }
    return self;
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
