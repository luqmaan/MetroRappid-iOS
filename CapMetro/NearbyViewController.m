//
//  NearbyViewController.m
//  CapMetro
//
//  Created by Luq on 2/10/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "NearbyViewController.h"
#import "GTFSDB.h"
#import "StopAnnotation.h"
#import "CAPNextBus.h"

@interface NearbyViewController ()

@property GTFSDB* gtfs;
@property CLLocationManager *locationManager;
@property NSMutableArray *stops;

@end

@implementation NearbyViewController

- (void)baseInit {
    NSLog(@"table view did load");
    self.gtfs = [[GTFSDB alloc] init];
    self.stops = [[NSMutableArray alloc] init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)refreshBtnPress:(id)sender {
    [self.locationManager startUpdatingLocation];
}

- (IBAction)loadArrivalsBtnPress:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath)
    {
        CAPNextBus *nb = self.stops[indexPath.row];
        NSLog(@"Loading arrivals for %@", nb.stop.name);
        nb.callback = ^void(){
            NSLog(@"nextBus callback called");
            [self.tableView reloadData];
        };
        [nb startUpdates];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];

    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500; // meters

    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *userLocation = [locations lastObject];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSMutableArray *data = [self.gtfs stopsForRoutes:@[@801, @803] nearLocation:userLocation withinRadius:2.0f];
        [self.stops removeAllObjects];

        for (CAPStop *stop in data) {
            CAPNextBus *nb = [[CAPNextBus alloc] initWithStop:stop];
            [self.stops addObject:nb];
        }
        NSLog(@"Got %lu stops", (unsigned long)self.stops.count);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });

    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *routeNumber = (UILabel *)[cell viewWithTag:1];
    UILabel *stopName = (UILabel *)[cell viewWithTag:2];
    UILabel *loadError = (UILabel *)[cell viewWithTag:11];
    UILabel *mainTime, *oldTime;

    CAPNextBus *nextBus = [self.stops objectAtIndex:indexPath.row];

    routeNumber.text = nextBus.stop.name;
    stopName.text = nextBus.stop.headsign;
    if (nextBus.lastUpdated) {
        if (nextBus.trips.count == 0) {
            loadError.text = @"No upcoming arrivals";
            loadError.hidden = NO;
            return cell;
        }
        
        for (int i = 0; i < 5; i++) {
            CAPTrip *trip = nextBus.trips[i];
            if (!trip) break;

            mainTime = (UILabel *)[cell viewWithTag:100 + i];
            oldTime = (UILabel *)[cell viewWithTag:101 + i];
            
            if (trip.realtime.valid) {
                oldTime.hidden = NO;
                oldTime.text = trip.tripTime;
            }
            mainTime.text = trip.estimatedTime;
            mainTime.hidden = NO;
        }

    }

    return cell;
}

@end
