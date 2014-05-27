//
//  CAPShape.h
//  MetroRappid
//
//  Created by Luq on 5/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface CAPShape : NSObject

@property NSString *shapeId;

// MKPolyline
@property (nonatomic, assign) CLLocationCoordinate2D *coords;
@property (nonatomic, assign) NSInteger count;

@end
