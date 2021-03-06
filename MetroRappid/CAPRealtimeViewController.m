//
//  CAPRealtimeViewController.m
//  MetroRappid
//
//  Created by Luq on 3/1/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRealtimeViewController.h"
#import "CAPRealtimeMapViewController.h"
#import <ProgressHUD/ProgressHUD.h>

@interface CAPRealtimeViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CAPRealtimeMapViewController* realtimeMapVC;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;

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
    for (CAPTrip *trip in self.stop.trips) if (trip.realtime.valid) vehicleCount++;
    NSLog(@"Updating map with %d vehicles", vehicleCount);

    self.navigationItem.title = self.stop.name;
    [self.realtimeMapVC setupMap:self.mapView withStop:self.stop];
    [self.realtimeMapVC updateMap:self.mapView withStop:self.stop];
    [self.realtimeMapVC zoomToAnnotationsMapView:self.mapView];
}

- (IBAction)refresh:(id)sender {
    // Do this so we can use them in tha block
    UIProgressView *progressView = self.progressBar;
    UIBarButtonItem *refreshButton = self.refreshBtn;
    CAPStop *stop = self.stop;
    CAPRealtimeMapViewController *realtimeMapVC = self.realtimeMapVC;
    MKMapView *mapView = self.mapView;

    progressView.progress = 0.0;
    refreshButton.enabled = NO;

    void (^progressCallback)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) = ^void(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        [progressView setProgress:totalBytesExpectedToRead / totalBytesExpectedToRead animated:YES];
    };

    void (^completedCallback)() = ^void(){
        refreshButton.enabled = YES;
        [UIView animateWithDuration:2.0f animations:^{
        }];
        [realtimeMapVC updateMap:mapView withStop:stop];
    };

    void (^errorCallback)(NSError *error) = ^void(NSError *error) {
        refreshButton.enabled = YES;
        [ProgressHUD showError:error.localizedDescription];
        progressView.progress = 0;
    };
    
    CAPNextBus *nextBus = [[CAPNextBus alloc] init];
    [nextBus updateStop:stop onProgress:progressCallback onCompleted:completedCallback onError:errorCallback];
}

@end
