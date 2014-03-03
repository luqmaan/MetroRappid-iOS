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
    self.mapView.delegate = self.realtimeMapVC;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated]; // FIXME: Is this needed?
}

- (void)update
{
    int vehicleCount = 0;
    for (CAPTrip *trip in self.stop.trips) if (trip.realtime.valid) vehicleCount++;

    self.navigationItem.title = self.stop.name;
//    self.navigationItem.prompt = [NSString stringWithFor  mat:@"%d vehicles", vehicleCount];
    NSLog(@"Updated with %d vehicles", vehicleCount);
    [self.realtimeMapVC setupMap:self.mapView withStop:self.stop];
}

@end
