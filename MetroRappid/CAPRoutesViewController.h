//
//  CAPRoutesViewController.h
//  MetroRappid
//
//  Created by Luq on 5/13/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CAPRoutesViewController : UICollectionViewController <CLLocationManagerDelegate>

- (IBAction)distanceChanged:(id)sender;

@end
