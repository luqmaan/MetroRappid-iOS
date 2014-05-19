//
//  CAPRoutesViewController.m
//  MetroRappid
//
//  Created by Luq on 5/13/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRoutesViewController.h"
#import "CAPRoutesDataSource.h"


@interface CAPRoutesViewController ()

@property CAPRoutesDataSource *routesDataSource;
@property CLLocationManager *locationManager;

@end


@implementation CAPRoutesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self layoutViews];
    
    
    self.routesDataSource = [[CAPRoutesDataSource alloc] init];
    self.collectionView.dataSource = self.routesDataSource;
    [self.routesDataSource loadFavorites];
    [self.collectionView reloadData];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100; // meters
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Layout

- (void)layoutViews
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)locationManager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"Got location %@", lastLocation);
    
//    if (lastLocation.horizontalAccuracy > kCLLocationAccuracyHundredMeters) {
        [locationManager stopUpdatingLocation];
        [self.routesDataSource loadNearby:lastLocation];
        [self.collectionView reloadData];
//    }
}

- (IBAction)distanceChanged:(UISlider *)sender {
    NSLog(@"DO THA STANKY LEG");
    float newDistance = (float)sender.value;
    NSLog(@"New distance %f", newDistance);
    [self.routesDataSource filterNearbyByDistance:newDistance];
    [sender setNeedsDisplay];
    [self.collectionView reloadSections:[[NSIndexSet alloc]initWithIndex:1]];
}

@end
