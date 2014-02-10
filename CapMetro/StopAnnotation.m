//
//  StopAnnotation.m
//  CapMetro
//
//  Created by Luq on 2/9/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "StopAnnotation.h"

@implementation StopAnnotation

@synthesize title, subtitle, coordinate, identifier;

-(id)initWithStop:(NSDictionary *)stop
{
    identifier = stop[@"stop_id"];
    subtitle = stop[@"stop_desc"];
    title = stop[@"stop_name"];
    coordinate = CLLocationCoordinate2DMake([stop[@"stop_lat"] doubleValue], [stop[@"stop_lon"] doubleValue]);
    return self;
}

@end
