//
//  CAPShape.m
//  MetroRappid
//
//  Created by Luq on 5/26/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPShape.h"
#import "GTFSDB.h"


@implementation CAPShape

- (id)initWithShapeId:(NSString *)shapeId
{
    if (self = [super init])
    {
        _shapeId = shapeId;
    }
    return self;
}

- (void)update
{
    NSMutableArray *data = [GTFSDB shapeWithId:self.shapeId];
    for (NSDictionary *d in data) {
        
    }
}

@end
