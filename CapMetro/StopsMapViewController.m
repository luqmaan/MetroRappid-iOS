//
//  StopsMapViewController.m
//  CapMetro
//
//  Created by Luq on 2/9/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "StopsMapViewController.h"
#import "GTFSDB.h"
#import "StopAnnotation.h"

@interface StopsMapViewController ()

@property GTFSDB* gtfs;

@end

@implementation StopsMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.gtfs = [[GTFSDB alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // FIXME: fix the is tracking thing to be toggleable
    BOOL isTracking = true;
    if (isTracking) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.01;
        mapRegion.span.longitudeDelta = 0.01;
        [self.mapView setCenterCoordinate: userLocation.location.coordinate
                                 animated: YES];
        [self.mapView setRegion:mapRegion animated: YES];
    }
    NSArray *nearbyStops = [self.gtfs stopsForLocation:userLocation.location andLimit:50];
    NSLog(@"Nearby stops %@", nearbyStops);
    for (NSDictionary *stop in nearbyStops) {
        StopAnnotation *annotation = [[StopAnnotation alloc] initWithStop:stop];
        [mapView addAnnotation:annotation];
    }
}

@end
