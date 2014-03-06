//
//  CAPRealtimeViewController.m
//  MetroRappid
//
//  Created by Luq on 3/1/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRealtimeViewController.h"
#import "CAPRealtimeMapViewController.h"

@interface CAPRealtimeViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CAPRealtimeMapViewController* realtimeMapVC;

@end

@implementation CAPRealtimeViewController

- (void)baseInit
{
    NSLog(@"CAPRealtimeViewController baseInit");
    self.realtimeMapVC = [[CAPRealtimeMapViewController alloc] init];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    int vehicleCount = 0;
    CAPStop *stop = self.nextBus.location.stops[self.nextBus.activeStopIndex];
    for (CAPTrip *trip in stop.trips) if (trip.realtime.valid) vehicleCount++;

    self.navigationItem.title = stop.name;
    NSLog(@"Updated with %d vehicles", vehicleCount);
    [self.realtimeMapVC setupMap:self.mapView withStop:stop];
}

- (IBAction)refresh:(id)sender {
    [self.nextBus startUpdates];
    CAPStop *stop = self.nextBus.location.stops[self.nextBus.activeStopIndex];
    [self.realtimeMapVC updateMap:self.mapView withStop:stop];
}

@end
