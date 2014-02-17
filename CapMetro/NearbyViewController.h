//
//  NearbyViewController.h
//  CapMetro
//
//  Created by Luq on 2/10/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NearbyViewController : UITableViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

- (IBAction)refreshBtnPress:(id)sender;
- (IBAction)loadArrivalsBtnPress:(id)sender;
- (IBAction)nextStopPress:(id)sender;

@end
