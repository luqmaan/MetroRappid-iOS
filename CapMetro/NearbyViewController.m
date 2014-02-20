//
//  NearbyViewController.m
//  CapMetro
//
//  Created by Luq on 2/10/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "NearbyViewController.h"
#import "GTFSDB.h"
#import "StopAnnotation.h"
#import "CAPNextBus.h"

@interface NearbyViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property GTFSDB* gtfs;
@property CLLocationManager *locationManager;
@property NSMutableArray *locations;
@property CAAnimationGroup *pulseAnimationGroup;

@end

@implementation NearbyViewController

- (void)baseInit {
    self.gtfs = [[GTFSDB alloc] init];
    self.locations = [[NSMutableArray alloc] init];

    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 0.3;
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.1];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.6];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.9;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:5.0];
    
    self.pulseAnimationGroup = [CAAnimationGroup animation];
    
    self.pulseAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    self.pulseAnimationGroup.autoreverses = YES;
    self.pulseAnimationGroup.repeatCount = INFINITY;
    self.pulseAnimationGroup.animations = @[scaleAnimation, opacityAnimation];
    self.pulseAnimationGroup.fillMode = kCAFillModeForwards;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100; // meters
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Data

- (void)loadArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        return;
    }
    CAPNextBus *nb = self.locations[indexPath.row];
    CAPStop *activeStop = nb.location.stops[nb.activeStopIndex];
    NSLog(@"Loading arrivals for %@", activeStop.name);

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:12];
    progressView.progress = 0.0f;
    progressView.hidden = NO;
    nb.progressCallback = ^void(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        progressView.progress = totalBytesExpectedToRead / totalBytesExpectedToRead;
    };
    
    nb.completedCallback = ^void(){
        NSLog(@"nextBus callback called");
        progressView.hidden = YES;
        [self.tableView reloadData];
    };
    [nb startUpdates];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *userLocation = [locations lastObject];
    NSLog(@"Got location %@", userLocation);
    
    if (userLocation.horizontalAccuracy > kCLLocationAccuracyHundredMeters) return;

    [manager stopUpdatingLocation];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        NSMutableArray *data = [self.gtfs locationsForRoutes:@[@801] nearLocation:userLocation withinRadius:200.0f];
        [self.locations removeAllObjects];

        for (CAPLocation *location in data) {
            CAPNextBus *nb = [[CAPNextBus alloc] initWithLocation:location];
            [self.locations addObject:nb];
        }
        NSLog(@"Got %lu locations", (unsigned long)self.locations.count);

        NSIndexPath *nearestStopIndexPath;
        int i = 0;
        while (i < self.locations.count) {
            CAPNextBus *nb = self.locations[i];
            if (nb.location.distanceIndex == 0) {
                nearestStopIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
            i++;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self loadArrivalsForCellAtIndexPath:nearestStopIndexPath];
            [self.tableView scrollToRowAtIndexPath:nearestStopIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    });

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier;
    
    CAPNextBus *nextBus = [self.locations objectAtIndex:indexPath.row];
    CAPLocation *location = nextBus.location;
    CAPStop *activeStop = location.stops[nextBus.activeStopIndex];
    
    if (activeStop.lastUpdated) {
        CellIdentifier = @"TripsCell";
    }
    else {
        CellIdentifier = @"Cell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *routeNumber = (UILabel *)[cell viewWithTag:1];
    UILabel *stopName = (UILabel *)[cell viewWithTag:2];
    UILabel *loadError = (UILabel *)[cell viewWithTag:11];
    UIView *routeIndicator = (UIView *)[cell viewWithTag:21];
    UIView *proximityIndicator = (UIView *)[cell viewWithTag:22];

    routeNumber.text = location.name;
    stopName.text = activeStop.headsign;
    
    proximityIndicator.layer.cornerRadius = 6.0f;
    proximityIndicator.layer.borderWidth = 2.0f;
    proximityIndicator.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    proximityIndicator.layer.borderColor = [[UIColor grayColor] CGColor];
    
    UISwipeGestureRecognizer *recognizerLeft;
    recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipeLeft:)];
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [tableView addGestureRecognizer:recognizerLeft];

    UISwipeGestureRecognizer *recognizerRight;
    recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipeRight:)];
    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [tableView addGestureRecognizer:recognizerRight];

    if ([CellIdentifier isEqualToString:@"TripsCell"]) {

        if (location.distanceIndex == 0) {
            
            UIView *proximityIndicatorOuter = (UIView *)[cell viewWithTag:24];
            
            NSLog(@"Showing proximity indcator %@ %@", (proximityIndicatorOuter.hidden ? @"hidden" : @"visible"), proximityIndicatorOuter);
            proximityIndicator.layer.borderColor = [[UIColor colorWithHue:0.576 saturation:0.867 brightness:0.976 alpha:1] CGColor];

            
            proximityIndicatorOuter.hidden = NO;
//            proximityIndicatorOuter.layer.borderColor = [[UIColor redColor] CGColor];
            proximityIndicatorOuter.layer.backgroundColor = [[UIColor colorWithHue:0.576 saturation:0.867 brightness:0.976 alpha:1] CGColor];
            proximityIndicatorOuter.layer.cornerRadius = 6.0f;

            [proximityIndicatorOuter.layer addAnimation:self.pulseAnimationGroup forKey:@"pulse"];
        }
        
        if (activeStop.trips.count == 0) {
            NSLog(@"No trips for %@", activeStop.trips);
            loadError.text = @"No upcoming arrivals";
            loadError.hidden = NO;
            return cell;
        }

        for (int i = 0; i < 3; i++) {
            if (i >= activeStop.trips.count) break;
            
            CAPTrip *trip = activeStop.trips[i];
            UILabel *mainTime, *oldTime;
            mainTime = (UILabel *)[cell viewWithTag:100 + (i * 2)];
            oldTime = (UILabel *)[cell viewWithTag:101 + (i * 2)];
            
            if (trip.realtime.valid) {
                mainTime.textColor = [UIColor colorWithHue:0.365 saturation:0.787 brightness:0.424 alpha:1];
                if (![trip.estimatedTime isEqualToString:trip.tripTime]) {
                    oldTime.hidden = NO;
                    oldTime.text = trip.tripTime;

                }
            }
            mainTime.text = trip.estimatedTime;
            mainTime.hidden = NO;
        }

    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CAPNextBus *nextBus = self.locations[indexPath.row];
    CAPLocation *location = nextBus.location;
    CAPStop *stop = location.stops[nextBus.activeStopIndex];
    
    if (stop.lastUpdated) {
        return 140.0f;
    }
    else return 90.0f;
}

#pragma mark - UIGestureRecognizerDelegate

- (void) cellSwipeLeft:(UISwipeGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:location];
    if (swipedIndexPath) {
        CAPNextBus *nb = self.locations[swipedIndexPath.row];
        [nb activateNextStop];
        [self.tableView reloadData];
        //        [self loadArrivalsForCellAtIndexPath:swipedIndexPath];
    }
}
- (void) cellSwipeRight:(UISwipeGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:location];
    if (swipedIndexPath) {
        [self loadArrivalsForCellAtIndexPath:swipedIndexPath];
    }
}

@end
