//
//  CAPRouteMapViewController.m
//  MetroRappid
//
//  Created by Luq on 5/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRouteMapViewController.h"
#import "GTFSDB.h"  // FIXME: Remove whatever calls this into a dataSource-esque class
#import "CAPTrip.h"


@interface CAPRouteMapViewController ()

@end


@implementation CAPRouteMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.route.routeId;
    
    NSMutableArray *tripsData = [GTFSDB activeTripsForRoute:self.route.routeId];
    NSMutableArray *trips = [[NSMutableArray alloc] init];
    for (NSDictionary *tripData in tripsData) {
        CAPTrip *trip = [[CAPTrip alloc] init];
        [trip updateWithGTFS:tripData];
        [trips addObject:trip];
    }
    NSLog(@"Got %d trips", (int)trips.count);

    NSMutableArray *shapes = [GTFSDB activeTripsForRoute:self.route.routeId];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
