//
//  CAPRoutesViewController.m
//  MetroRappid
//
//  Created by Luq on 5/13/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRoutesViewController.h"
#import "CAPRoutesDataSource.h"
#import "CAPRouteMapViewController.h"


@interface CAPRoutesViewController ()

@property CAPRoutesDataSource *routesDataSource;
@property CLLocationManager *locationManager;

@end


@implementation CAPRoutesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.routesDataSource = [[CAPRoutesDataSource alloc] init];
    self.collectionView.dataSource = self.routesDataSource;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100; // meters
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.routesDataSource loadFavoriteRoutes];
        [self.routesDataSource loadAllRoutes];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self.locationManager startUpdatingLocation];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:@"RouteCellSelectedSegue"]) {
       CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.collectionView];
       NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
       CAPRoute *route = [self.routesDataSource objectForIndexPath:indexPath];
       
       NSLog(@"RouteCellSelectedSegue with %@", route);
       
       CAPRouteMapViewController *destinationVC = [segue destinationViewController];
       destinationVC.route = route;
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)locationManager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"Got location %@", lastLocation);
    
    if (lastLocation.horizontalAccuracy > kCLLocationAccuracyKilometer) {
        [locationManager stopUpdatingLocation];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.routesDataSource loadNearbyRoutes:lastLocation];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        });
    }
}

@end
