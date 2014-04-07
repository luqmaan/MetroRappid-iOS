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

@property GTFSDB *gtfs;
@property CLLocationManager *locationManager;

@property NSMutableArray *locations;
@property (nonatomic, assign) GTFSDirection gtfsDirection;

@property NSIndexPath *lastClickedIndexPath;  // FIXME: What is this for? Remove it.

@property CAAnimationGroup *pulseAnimationGroup;
@property CAAnimationGroup *labelAnimationGroup;

@end

@implementation CAPNearbyViewController

- (void)baseInit {
    
    
    // Don't want to make real requests in Travis CI
    BOOL isRunningTests = [[[NSProcessInfo processInfo] environment] objectForKey:@"isRunningTests"];
    NSLog(@"Is running tests: %@", [[[NSProcessInfo processInfo] environment] objectForKey:@"isRunningTests"] ? @"Yes" : @"No");
    if (isRunningTests) return;
    
    NSLog(@"Init CAPNearbyViewController");
    self.gtfs = [[GTFSDB alloc] init];
    
    self.locations = [[NSMutableArray alloc] init];
    self.gtfsDirection = GTFSNorthbound;
    
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
    NSLog(@"Did receive memory warning");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delaysContentTouches = NO;
    [self loadLocationsGTFS];
    [self updateLocation];
}

#pragma mark - Data

- (void)loadArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        [ProgressHUD showError:@"Can't load arrivals"];
        return;
    }
    CAPNextBus *nb = [[CAPNextBus alloc] init];  // FIXME: Does this need to be created every time? Is it better as a property?

    CAPStop *activeStop = self.locations[indexPath.row];
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
    [progressView setProgress:0.0f animated:NO];
    [progressView setProgress:0.1f animated:YES];
    progressView.hidden = NO;

    void (^progressCallback)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) = ^void(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        [progressView setProgress:totalBytesExpectedToRead / totalBytesExpectedToRead animated:YES];
    };

    void (^completedCallback)() = ^void(){
        NSLog(@"nextBus callback called");
        progressView.hidden = YES;
        activeStop.showsTrips = YES;
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

    void (^errorCallback)(NSError *error) = ^void(NSError *error) {
        [ProgressHUD showError:error.localizedDescription];
        [progressView setProgress:0.0f animated:NO];
        progressView.hidden = YES;
        [self.tableView reloadData];
    };

    [nb updateStop:activeStop onProgress:progressCallback onCompleted:completedCallback onError:errorCallback];
}

- (void)hideArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CAPStop *activeStop = self.locations[indexPath.row];
    NSLog(@"Hiding arrivals for %@", activeStop.name);
    activeStop.showsTrips = NO;
    [self.tableView reloadData];
}

- (void)toggleArrivalsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CAPStop *activeStop = self.locations[indexPath.row];
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
        
        NSMutableArray *data = [self.gtfs locationsForRoutes:@[@801] nearLocation:self.locationManager.location inDirection:self.gtfsDirection];
        [self.locations removeAllObjects];
        
        // FIXME: lol just copy or something
        for (CAPStop *stop in data) {
            [self.locations addObject:stop];
        }
        NSLog(@"Got %lu locations", (unsigned long)self.locations.count);
        
        NSIndexPath *nearestStopIndexPath;
        int i = 0;
        while (i < self.locations.count) {
            CAPStop *stop = self.locations[i];
            if (stop.distanceIndex == 0) {
                nearestStopIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
            i++;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.gtfsDirection == GTFSNorthbound) self.navigationItem.title = @"801 NORTH";
            if (self.gtfsDirection == GTFSSouthbound) self.navigationItem.title = @"801 SOUTH";
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
    
    CAPStop *stop = self.locations[indexPath.row];
    
    if (stop.showsTrips) {
        CellIdentifier = @"TripsCell";
    }
    else {
        CellIdentifier = @"Cell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *routeNumber = (UILabel *)[cell viewWithTag:1];
    UILabel *distance = (UILabel *)[cell viewWithTag:2];
    UIView *proximityIndicator = (UIView *)[cell viewWithTag:22];

    routeNumber.text = stop.name;
    if (!stop.distance) distance.hidden = YES;
    else {
        distance.hidden = NO;
        distance.text = stop.distancePretty;
    }

    proximityIndicator.layer.cornerRadius = 6.0f;
    proximityIndicator.layer.borderWidth = 2.0f;
    proximityIndicator.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    proximityIndicator.layer.borderColor = [[UIColor grayColor] CGColor];
    
    if (stop.distanceIndex == 0) {
        UIView *proximityIndicatorOuter = (UIView *)[cell viewWithTag:24];
        
        proximityIndicator.layer.borderColor = [[UIColor colorWithHue:0.576 saturation:0.867 brightness:0.976 alpha:1] CGColor];
    
        proximityIndicatorOuter.hidden = NO;
        proximityIndicatorOuter.layer.backgroundColor = [[UIColor colorWithHue:0.576 saturation:0.867 brightness:0.976 alpha:1] CGColor];
        proximityIndicatorOuter.layer.cornerRadius = 6.0f;
        
        [proximityIndicatorOuter.layer addAnimation:self.pulseAnimationGroup forKey:@"pulse"];
    }
    
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:12];
    [progressView setProgress:0 animated:NO];

    if ([CellIdentifier isEqualToString:@"TripsCell"]) {
        int numAdded = 0;
        int numLabels = 3;
        int i = 0;
        
        NSLog(@"stop.trips.count %d", (int)stop.trips.count);
        while (numAdded < numLabels) {
            if (i >= stop.trips.count) break;
            CAPTrip *trip = stop.trips[i];
            i++;
            if (!trip.realtime.valid) {
                continue;
            };
            
            UILabel *mainTime;
            mainTime = (UILabel *)[cell viewWithTag:100 + (numAdded * 2)];
            
            if (indexPath == self.lastClickedIndexPath) [mainTime.layer addAnimation:self.labelAnimationGroup forKey:nil];
            mainTime.text = trip.estimatedTime;
            mainTime.hidden = NO;
            numAdded++;
        }
        UILabel *error = (UILabel *)[cell viewWithTag:110];
        if (numAdded == 0) {
            error.hidden = NO;
        }
        else {
            error.hidden = YES;
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

    CAPStop *stop = self.locations[indexPath.row];
    
    if (stop.showsTrips) return 90.0f;
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
    self.gtfsDirection = (int)control.selectedSegmentIndex;
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
        UIButton *button = (UIButton *)sender;
        UITableViewCell *cell = (UITableViewCell*)button.superview.superview.superview; // FIXME: ;_;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        CAPRealtimeViewController *realtimeVC = segue.destinationViewController;
        CAPStop *stop = self.locations[indexPath.row];
        realtimeVC.stop = stop;
    }
}

@end
