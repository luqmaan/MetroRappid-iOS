//
//  NearbyViewController.m
//  CapMetro
//
//  Created by Luq on 2/10/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <ProgressHUD/ProgressHUD.h>

#import "CAPNearbyViewController.h"
#import "GTFSDB.h"
#import "CAPNextBus.h"
#import "CAPRealtimeViewController.h"

@interface CAPNearbyViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property GTFSDB* gtfs;
@property CLLocationManager *locationManager;
@property NSMutableArray *locations;
@property CAAnimationGroup *pulseAnimationGroup;
@property CAAnimationGroup *labelAnimationGroup;
@property NSIndexPath *lastClickedIndexPath;
@property (nonatomic, assign) int directionId;

@end

@implementation CAPNearbyViewController

- (void)baseInit {
    NSLog(@"Init NearbyViewController");
    self.gtfs = [[GTFSDB alloc] init];
    
    self.locations = [[NSMutableArray alloc] init];
    self.directionId = 0;
    
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
    
    CABasicAnimation *timeOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    timeOpacityAnimation.duration = 0.5;
    timeOpacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    timeOpacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    self.labelAnimationGroup = [CAAnimationGroup animation];
    self.labelAnimationGroup.autoreverses = NO;
    self.labelAnimationGroup.duration = 0.5;
    self.labelAnimationGroup.animations = @[timeOpacityAnimation];
    self.labelAnimationGroup.fillMode = kCAFillModeForwards;
    self.labelAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    if (nil == self.locationManager) self.  locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100; // meters

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
    self.tableView.delaysContentTouches = NO;
    [self loadLocationsGTFS];
    [self updateLocation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appDidEnterForeground:(NSNotification *)notification
{
    [self updateLocation];
}

#pragma mark - Data

- (void)loadArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        [ProgressHUD showError:@"Can't load arrivals"];
        return;
    }
    CAPNextBus *nb = self.locations[indexPath.row];
    CAPStop *activeStop = nb.location.stops[nb.activeStopIndex];
    NSLog(@"Loading arrivals for %@", activeStop.name);

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    [UIView animateWithDuration:0.2f animations:^{
        UILabel *error = (UILabel *)[cell viewWithTag:110];
        UIButton *refreshBtn = (UIButton *)[cell viewWithTag:200];
        error.layer.opacity = 0.5;
        refreshBtn.layer.opacity = 0.5;
        for (int i = 0; i < 3; i++) {
            UILabel *mainTime = (UILabel *)[cell viewWithTag:100 + (i * 2)];
            mainTime.layer.opacity = 0.5;
        }
    }];
    
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:12];
    [progressView setProgress:0.1f animated:YES];
    progressView.hidden = NO;
    nb.progressCallback = ^void(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        [progressView setProgress:totalBytesExpectedToRead / totalBytesExpectedToRead animated:YES];
    };
    nb.completedCallback = ^void(){
        NSLog(@"nextBus callback called");
        progressView.hidden = YES;
        activeStop.showsTrips = YES;
        if (activeStop.trips.count == 0) {
            activeStop.showsTrips = NO;
        }
        [self.tableView reloadData];
        [UIView animateWithDuration:0.4f animations:^{
            UILabel *error = (UILabel *)[cell viewWithTag:110];
            UIButton *refreshBtn = (UIButton *)[cell viewWithTag:200];
            error.layer.opacity = 1.0;
            refreshBtn.layer.opacity = 1.0;
            for (int i = 0; i < 3; i++) {
                UILabel *mainTime = (UILabel *)[cell viewWithTag:100 + (i * 2)];
                mainTime.layer.opacity = 1.0;
            }
        }];
    };
    nb.errorCallback = ^void(NSError *error) {
        [ProgressHUD showError:error.localizedDescription];
        progressView.progress = 0;
        progressView.hidden = YES;
        [self.tableView reloadData];
    };
    [nb startUpdates];
}

- (void)hideArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CAPNextBus *nb = self.locations[indexPath.row];
    CAPStop *activeStop = nb.location.stops[nb.activeStopIndex];
    NSLog(@"Hiding arrivals for %@", activeStop.name);
    activeStop.showsTrips = NO;
    [self.tableView reloadData];
}

- (void)toggleArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CAPNextBus *nb = self.locations[indexPath.row];
    CAPStop *activeStop = nb.location.stops[nb.activeStopIndex];
    NSLog(@"Toggling arrivals for %@", activeStop.name);
    if (activeStop.showsTrips) {
        [self hideArrivalsForCellAtIndexPath:indexPath];
    }
    else {
        [self loadArrivalsForCellAtIndexPath:indexPath];
    }
}

- (void)loadLocationsGTFS
{
    BOOL __block waitingForGTFS = NO;
    if (!self.gtfs.ready) {
        waitingForGTFS = YES;
        [ProgressHUD show:@"Loading Database"];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        while (!self.gtfs.ready);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (waitingForGTFS == YES) {
                waitingForGTFS = NO;
                // Why does the ProgressHUD get dismissed before we get here? ;_;
                [ProgressHUD showSuccess:nil];
            }
        });
        
        NSMutableArray *data = [self.gtfs locationsForRoutes:@[@801] nearLocation:self.locationManager.location inDirection:self.directionId];
        [self.locations removeAllObjects];
        
        for (CAPLocation *location in data) {
            CAPNextBus *nb = [[CAPNextBus alloc] initWithLocation:location andRoute:@"801"];
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
            if (self.directionId == 0) self.navigationItem.title = @"801 North";
            if (self.directionId == 1) self.navigationItem.title = @"801 South";
            [self.tableView reloadData];
            [self loadArrivalsForCellAtIndexPath:nearestStopIndexPath];
            [self.tableView scrollToRowAtIndexPath:nearestStopIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)updateLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *userLocation = [locations lastObject];
    NSLog(@"Got location %@", userLocation);
    
    if (userLocation.horizontalAccuracy > kCLLocationAccuracyHundredMeters) {
        [manager stopUpdatingLocation];
        [manager startMonitoringSignificantLocationChanges];
    };
    
    [self loadLocationsGTFS];
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
    
    if (activeStop.trips.count == 0) {
        CellIdentifier = @"Cell";
    }
    else if (activeStop.showsTrips) {
        CellIdentifier = @"TripsCell";
    }
    else {
        CellIdentifier = @"Cell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *routeNumber = (UILabel *)[cell viewWithTag:1];
    UIView *proximityIndicator = (UIView *)[cell viewWithTag:22];

    routeNumber.text = location.name;
    
    proximityIndicator.layer.cornerRadius = 6.0f;
    proximityIndicator.layer.borderWidth = 2.0f;
    proximityIndicator.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    proximityIndicator.layer.borderColor = [[UIColor grayColor] CGColor];
    
    if (location.distanceIndex == 0) {
        UIView *proximityIndicatorOuter = (UIView *)[cell viewWithTag:24];
        
        proximityIndicator.layer.borderColor = [[UIColor colorWithHue:0.576 saturation:0.867 brightness:0.976 alpha:1] CGColor];
        
        proximityIndicatorOuter.hidden = NO;
        proximityIndicatorOuter.layer.backgroundColor = [[UIColor colorWithHue:0.576 saturation:0.867 brightness:0.976 alpha:1] CGColor];
        proximityIndicatorOuter.layer.cornerRadius = 6.0f;
        
        [proximityIndicatorOuter.layer addAnimation:self.pulseAnimationGroup forKey:@"pulse"];
    }

    if ([CellIdentifier isEqualToString:@"TripsCell"]) {
        int numAdded = 0;
        int numLabels = 3;
        
        for (int i = 0; i < numLabels; i++) {
            if (i >= activeStop.trips.count) break;
            CAPTrip *trip = activeStop.trips[i];
            if (!trip.realtime.valid) {
                i = MAX(i, i-1);
                continue;
            };
            
            UILabel *mainTime;
            mainTime = (UILabel *)[cell viewWithTag:100 + (numAdded * 2)];
            
            if (indexPath == self.lastClickedIndexPath) [mainTime.layer addAnimation:self.labelAnimationGroup forKey:nil];
            mainTime.text = trip.estimatedTime;
            mainTime.hidden = NO;
            numAdded++;
        }
        if (numAdded == 0) {
            UILabel *error = (UILabel *)[cell viewWithTag:110];
            error.hidden = NO;
        }
        for (int i = numAdded; i < numLabels; i++) {
            UILabel *time = (UILabel *)[cell viewWithTag:100 + (numAdded * 2)];
            time.text = @"";
            time.hidden = YES;
        }
    }
    
    // http://stackoverflow.com/questions/19256996/uibutton-not-showing-highlight-on-tap-in-ios7
    for (id obj in cell.subviews) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"]) {
            UIScrollView *scroll = (UIScrollView *) obj;
            scroll.delaysContentTouches = NO;
            break;
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
    
    if (stop.showsTrips && stop.trips.count > 0) return 90.0f;
    else return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleArrivalsForCellAtIndexPath:indexPath];
}

#pragma mark - UIGestureRecognizerDelegate


#pragma mark - IBActions

- (IBAction)reloadBtnPress:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil) {
        [self loadArrivalsForCellAtIndexPath:indexPath];
    }
}
- (IBAction)toggleDirection:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    self.directionId = control.selectedSegmentIndex;
    [self loadLocationsGTFS];
}

# pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"RealtimeMapViewSegue"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (!indexPath) {
            NSLog(@"Could not find indexPathForSelectedRow");
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RealtimeMapViewSegue"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        CAPRealtimeViewController *realtimeVC = segue.destinationViewController;
        CAPNextBus *nextBus = self.locations[indexPath.row];
        realtimeVC.nextBus = nextBus;
    }
}

@end
