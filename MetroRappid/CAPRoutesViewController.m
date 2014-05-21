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
    layout.collectionView.contentInset = UIEdgeInsetsMake(10, 15, 10, 15);
//    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
    float newDistance = (float)sender.value;
    NSLog(@"New distance %f", newDistance);
    
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *indexPathsOld = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.routesDataSource numberOfItemsInSectionWithKey:@"nearby"]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:[self.routesDataSource sectionForKey:@"nearby"]];
            [indexPathsOld addObject:indexPath];
        }
        [self.routesDataSource filterNearbyByDistance:newDistance];
        [self.collectionView deleteItemsAtIndexPaths:indexPathsOld];
        
        NSMutableArray *indexPathsNew = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.routesDataSource numberOfItemsInSectionWithKey:@"nearby"]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:[self.routesDataSource sectionForKey:@"nearby"]];
            [indexPathsNew addObject:indexPath];
        }
        [self.collectionView insertItemsAtIndexPaths:indexPathsNew];
    } completion:nil];
}

@end
